SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format
Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


--Populate Property Address Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)  as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NvarCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NvarCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--WHERE PropertyAddress like '%FOX%'

--OwnerAddress
SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NvarCHAR(255);
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NvarCHAR(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NvarCHAR(255);
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

--Change Y and N to Yes and No in "Sold as Vacant' field
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
Order by 2

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

--Remove Duplicates
WITH  RowNumCTE AS(
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

FROM PortfolioProject.dbo.NashvilleHousing
)

SELECT *
from RowNumCTE
WHERE row_num > 1