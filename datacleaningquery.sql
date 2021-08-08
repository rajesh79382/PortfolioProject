--standardize date format

select SaleDate,CONVERT(date,saledate) as date
from [dbo].[Sheet1$]

update [dbo].[Sheet1$]
set SaleDate = CONVERT(date,saledate)

--populate property data
--problems: there will be null values, duplicates ,
select PropertyAddress
from [dbo].[Sheet1$]
where PropertyAddress is null

--self joining table to populate those null values

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from [dbo].[Sheet1$] a join 
[dbo].[Sheet1$] b on a.ParcelID= b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--updating the table to remove those null values
update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [dbo].[Sheet1$] as a join 
[dbo].[Sheet1$] as b on a.ParcelID= b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address
select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress)) as address
from Sheet1$


Select PropertyAddress
From Sheet1$
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From Sheet1$


ALTER TABLE Sheet1$
Add PropertySplitAddress Nvarchar(255);

Update Sheet1$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Sheet1$
Add PropertySplitCity Nvarchar(255);

Update Sheet1$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select PropertySplitCity
from Sheet1$

--similar thing for owner address
Select OwnerAddress
From [dbo].[Sheet1$]

ALTER TABLE Sheet1$
Add OwnerSplitAddress Nvarchar(255);

Update Sheet1$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Sheet1$
Add OwnerSplitCity Nvarchar(255);

Update Sheet1$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Sheet1$
Add OwnerSplitState Nvarchar(255);

Update Sheet1$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Sheet1$

--updating similar things to one type (soldasvacant has values y,n, yes, no)

select distinct SoldAsVacant
from Sheet1$

update Sheet1$
set SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y'

update Sheet1$
set SoldAsVacant = 'No'
where SoldAsVacant = 'N'

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from Sheet1$
group by SoldAsVacant

--Remove duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From [dbo].[Sheet1$]
--oer by ParcelID
)
Delete 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress