/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------------------------------

--Populate Property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

------------------------------------------------------------

--Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), --parsename only works for . but replace can be used to replace period(.) into comma(,)
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------

--Change Y and N to Yes to No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


------------------------------------------------------------------

--Remove duplicate

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress

--DELETE FROM RowNumCTE
--WHERE row_num>1

-----------------------------------------------------

--DELETE UNUSED COLUMNS

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate