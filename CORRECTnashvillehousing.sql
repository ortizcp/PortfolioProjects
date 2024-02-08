SELECT *
FROM housing.nashville_housing;

-- Standardized Data Format

SELECT SaleDate,
	DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), '%Y-%m-%d') AS ConvertedSaleDate
FROM housing.nashville_housing;

ALTER TABLE housing.nashville_housing
ADD COLUMN  ConvertedSaleDate DATE;

SET SQL_SAFE_UPDATES = 0;

UPDATE housing.nashville_housing
SET ConvertedSaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y');

-- Populate Property Address Data

SELECT *
FROM housing.nashville_housing
-- WHERE PropertyAddress is null
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress) AS MergedAddress
FROM housing.nashville_housing a
JOIN housing.nashville_housing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null;

UPDATE housing.nashville_housing a
JOIN (SELECT * FROM housing.nashville_housing) b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress) 
WHERE a.PropertyAddress IS NULL;

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM housing.nashville_housing;
-- WHERE PropertyAddress is null
-- ORDER BY ParcelID

SELECT 
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
    SUBSTRING_INDEX(PropertyAddress, ',', -1) AS City
FROM housing.nashville_housing;

ALTER TABLE housing.nashville_housing
ADD COLUMN  PropertySplitAddress VARCHAR(255);

UPDATE housing.nashville_housing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE housing.nashville_housing
ADD COLUMN  PropertySplitCity VARCHAR(255);

UPDATE housing.nashville_housing
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

SELECT *
FROM housing.nashville_housing;


SELECT OwnerAddress
FROM housing.nashville_housing;

SELECT
    TRIM(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1)) AS ParsedAddress,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1)) AS ParsedCity,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3), '.', -1)) AS ParsedState
FROM
    housing.nashville_housing;
    
ALTER TABLE housing.nashville_housing
ADD COLUMN  OwnerSplitAddress VARCHAR(255);

UPDATE housing.nashville_housing
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1));

ALTER TABLE housing.nashville_housing
ADD COLUMN  OwnerSplitCity VARCHAR(255);

UPDATE housing.nashville_housing
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1));

ALTER TABLE housing.nashville_housing
ADD COLUMN  OwnerSplitState VARCHAR(255);

UPDATE housing.nashville_housing
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3), '.', -1));

SELECT *
FROM housing.nashville_housing;

-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select distinct(SoldAsVacant), count(SoldAsVacant)
FROM housing.nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
	END AS SoldAsVacantFormatted
FROM housing.nashville_housing;

UPDATE housing.nashville_housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
	END;

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
	row_number() OVER (
    PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                   UniqueID
                   ) row_num
FROM housing.nashville_housing
-- ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

DELETE FROM housing.nashville_housing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM housing.nashville_housing
    ) AS RowNumCTE
    WHERE row_num > 1
);


-- Delete Unused Columns

SELECT *
FROM housing.nashville_housing;

ALTER TABLE housing.nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

ALTER TABLE housing.nashville_housing
DROP COLUMN SaleDate;

SELECT *
FROM housing.nashville_housing;