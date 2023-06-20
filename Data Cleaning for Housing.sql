-- Data Cleaning

SELECT * FROM PortfolioProject.Housing;

-- Standardize Date Format

SELECT SaleDate, DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), '%m/%d/%Y') AS SaleDateConverted
FROM PortfolioProject.Housing;

ALTER TABLE Housing
ADD SaleDateConverted DATE;

UPDATE Housing
SET SaleDateConverted = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), '%m/%d/%Y')
WHERE UniqueID <> 0;

-- Populate Property Address Data
-- ISNULL in Mysql ISNULL(expression) = replacement_value; in SQL server ISNULL(expression, replacement_value)

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress) = b.PropertyAddress
FROM PortfolioProject.Housing a
JOIN PortfolioProject.Housing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Break out Address into Individual Column(Address, City, State)

SELECT 
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address1,
    SUBSTRING_INDEX(PropertyAddress, ',', -1) AS Address2
FROM PortfolioProject.Housing;

SELECT OwnerAddress
FROM PortfolioProject.Housing;

SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address3,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS Address4,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS Address5
FROM PortfolioProject.Housing;

-- Change Y or N to Yes or No

SELECT distinct(SoldAsVacant)
FROM PortfolioProject.Housing;

SELECT SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END
	     AS SoldAsVacantUpdated
FROM PortfolioProject.Housing;

UPDATE PortfolioProject.Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END;

-- Remove Duplicates
-- CTEs are used to simplify complex queries, or perform recursive operations that require self-reference within a query
-- Window function

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, PropertyAddress ORDER BY UniqueID) AS row_num
FROM PortfolioProject.Housing
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Delete Unused Columns

SELECT *
FROM PortfolioProject.Housing;

ALTER TABLE PortfolioProject.Housing
DROP COLUMN TaxDistrict, SaleDateConverted;







