# SQL Portfolio Queries

This repository contains SQL scripts for two portfolio projects: Covid-19 data analysis and Nashville housing data cleaning and transformation. The scripts include data selection, calculations, data cleaning, and preparation for analysis.

## Covid-19 Data (`SQLQuery1.sql`)

* Select and order basic CovidDeaths columns  
* Calculate death ratio and percentage of population infected  
* Filter infection data for the United States  
* Identify countries with highest infection rates and total deaths  
* Aggregate deaths by continent and calculate death rate percentages  
* Track total and cumulative vaccinations by country  
* Create temporary table and permanent view for population vs cumulative vaccinations  

## Nashville Housing Data (`SQLQuery5.sql`)

* Convert `SaleDate` to proper DATE format  
* Fill missing `PropertyAddress` values using records with same `ParcelID`  
* Split `PropertyAddress` and `OwnerAddress` into components (Address City State)  
* Standardize `SoldAsVacant` values  
* Remove duplicate records and replace NULL `OwnerName` with 'Unknown'  
* Trim extra spaces from addresses  
* Create `PriceCategory` based on `SalePrice`  
* Identify records with missing `SalePrice`  
* Standardize `LandUse` text  
* Drop unused columns after splitting addresses  

## Usage

1. Open the `.sql` files in your SQL environment (SQL Server Management Studio or similar)  
2. Execute the scripts step by step  
3. Review temporary tables views and cleaned datasets for analysis  

Both scripts are designed to prepare datasets for further analysis visualization or reporting.
