-- Nashville Housing Data Cleaning
-- Import data into MSSQL

-- View entire data
select * from ['Housing data']


-- SaleDate in DateTiime formart. (Convert to only Date format) 2013-04-09 00:00:00.000
alter table ['Housing data']
alter column SaleDate date


-- Join table on same table
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress 
from ['Housing data'] as a
join ['Housing data'] as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


-- Populate Property Address data
Select *
From ['Housing data']
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From ['Housing data'] a
JOIN ['Housing data'] b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From ['Housing data'] a
JOIN ['Housing data'] b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From ['Housing data']
Where PropertyAddress is null
order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From ['Housing data']

ALTER TABLE ['Housing data']
Add PropertySplitAddress Nvarchar(255);

Update ['Housing data']
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE ['Housing data']
Add PropertySplitCity Nvarchar(255);

Update ['Housing data']
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


-- View Table
Select *
From ['Housing data']


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From ['Housing data']


ALTER TABLE ['Housing data']
Add OwnerSplitAddress Nvarchar(255);

Update ['Housing data']
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE ['Housing data']
Add OwnerSplitCity Nvarchar(255);

Update ['Housing data']
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE ['Housing data']
Add OwnerSplitState Nvarchar(255);

Update ['Housing data']
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From ['Housing data']


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From ['Housing data']
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From ['Housing data']

Update ['Housing data']
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference)
From ['Housing data']
ORDER BY UniqueID, row_num
order by ParcelID

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From ['Housing data']

-- Delete Unused Columns
Select *
From ['Housing data']

ALTER TABLE [‘Housing data’]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate