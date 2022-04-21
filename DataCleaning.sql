/* Cleaning Data in SQL Series */

SELECT SaleDate, SaleDateConverted
FROM nashvillehousing;

/* Standardize Date Format */

SELECT SaleDate, STR_TO_DATE(SaleDate,'%e-%b-%y')
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD SaleDateConverted Date;

UPDATE nashvillehousing
SET SaleDateConverted = STR_TO_DATE(SaleDate,'%e-%b-%y');

SELECT SaleDate, SaleDateConverted
FROM nashvillehousing;

/* Populate Property Address Data */

SELECT SaleDateConverted, PropertyAddress
FROM nashvillehousing
WHERE PropertyAddress is NOT NULL; 

UPDATE nashvillehousing 
SET PropertyAddress = NULL 
WHERE length(PropertyAddress)=0;

SELECT *
FROM nashvillehousing
/*WHERE PropertyAddress IS NULL;*/
ORDER BY ParcelID;

	/* Some rows have a PropertyAddress that is Null. I'm going to use a JOIN to populate the adress based on its ParcelID. */

SELECT a.ParcelID, a.propertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashvillehousing a
JOIN nashvillehousing b
	ON a.ParcelID = b.ParcelID 
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashvillehousing a
JOIN nashvillehousing b
	ON a.ParcelID = b.ParcelID 
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

/* Breaking Out Address Into Individual Columns (Address, City, State) */

SELECT PropertyAddress
FROM nashvillehousing;

SELECT 
SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) + 1) as Address
FROM nashvillehousing;

/*SELECT (ALTERNATIVE OPTION TO ABOBE STATEMENT)
SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) + 1,  CHAR_LENGTH(PropertyAddress)) as Address
FROM nashvillehousing;*/

ALTER TABLE nashvillehousing
Add PropertySplitAddress varchar(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1);

ALTER TABLE nashvillehousing
Add PropertySplitCity varchar(255);

UPDATE nashvillehousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) + 1);

SELECT *
FROM nashvillehousing; 

----------------------

SELECT OwnerAddress
FROM nashvillehousing;

SELECT
SUBSTRING_INDEX(REPLACE(OwnerAddress, ',','.'),'.', 1) as Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',','.'),'.', -2),'.',1) as City,
SUBSTRING_INDEX(REPLACE(OwnerAddress, ',','.'),'.', -1) as State
FROM nashvillehousing;

ALTER TABLE nashvillehousing
Add OwnerSplitAddress varchar(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',','.'),'.', 1);

ALTER TABLE nashvillehousing
Add OwnerSplitCity varchar(255);

UPDATE nashvillehousing
SET OwnerSplitCity =  SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',','.'),'.', -2),'.',1);

ALTER TABLE nashvillehousing
Add OwnerSplitState varchar(255);

UPDATE nashvillehousing
SET OwnerSplitState =  SUBSTRING_INDEX(REPLACE(OwnerAddress, ',','.'),'.', -1);

SELECT *
FROM nashvillehousing;


/* Change Y and N to Yes and No in "Sold as Vacant" Field */

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY(SoldAsVacant)
ORDER BY 2;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END
FROM nashvillehousing;

UPDATE nashvillehousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;
/* REMOVE DUPLICATES */
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY UniqueID) row_num
FROM nashvillehousing
ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

/* DELETE UNUSED COLUMNS */

SELECT *
FROM nashvillehousing;

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, 
DROP COLUMN PropertyAddress, 
DROP COLUMN TaxDistrict;

ALTER TABLE nashvillehousing
DROP COLUMN SaleDate;
