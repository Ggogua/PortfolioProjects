-- Convert SaleDate to proper DATE format

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);


-- Fill missing PropertyAddress values using records with same ParcelID

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;


-- Split PropertyAddress into Address and City

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
    PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
    PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));


-- Split OwnerAddress into Address, City, and State

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
    OwnerSplitCity NVARCHAR(255),
    OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


-- Standardize SoldAsVacant values (Y/N → Yes/No)

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant =
CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;


-- Remove duplicate records

WITH RowNumCTE AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID
) row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;


-- Replace NULL OwnerName values with 'Unknown'

UPDATE PortfolioProject..NashvilleHousing
SET OwnerName = 'Unknown'
WHERE OwnerName IS NULL;


-- Trim extra spaces from PropertyAddress and OwnerAddress

UPDATE PortfolioProject..NashvilleHousing
SET PropertyAddress = LTRIM(RTRIM(PropertyAddress)),
    OwnerAddress = LTRIM(RTRIM(OwnerAddress));


-- Create a price category based on SalePrice

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PriceCategory NVARCHAR(50);

UPDATE PortfolioProject..NashvilleHousing
SET PriceCategory =
CASE
WHEN SalePrice < 100000 THEN 'Low'
WHEN SalePrice BETWEEN 100000 AND 300000 THEN 'Medium'
ELSE 'High'
END;


-- Identify records with missing SalePrice

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE SalePrice IS NULL;


-- Standardize LandUse text format

UPDATE PortfolioProject..NashvilleHousing
SET LandUse = UPPER(LandUse);


-- Drop unused columns after splitting addresses

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate;
