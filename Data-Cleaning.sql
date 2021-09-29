/*

Lets hit the ground running

*/

select *
from Nashville.dbo.sheet1$

----------------------------------------------------------

-- Standardize Date Format

Update Nashville.dbo.sheet1$
SET SaleDate = CONVERT(Date,SaleDate);

----------------------------------------------------------

-- Populate Property Address Data

select *
From nashville.dbo.sheet1$
order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville.dbo.Sheet1$ a
JOIN Nashville.dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville.dbo.Sheet1$ a
JOIN Nashville.dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

--------------------------------------------------------------------------------------

-- Lets break out address into address, city and state

Select PropertyAddress
From Nashville.dbo.Sheet1$;

select 
substring(propertyaddress,1,CHARINDEX(',',propertyaddress) -1) as address
, SUBSTRING(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress)) as address
from Nashville.dbo.Sheet1$;

alter table nashville.dbo.sheet1$
add propertysplitaddress nvarchar(255);

update Nashville.dbo.Sheet1$
set propertysplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

alter table nashville.dbo.sheet1$
add propertysplitcity nvarchar(255);

update Nashville.dbo.Sheet1$
set propertysplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


select *
from Nashville.dbo.Sheet1$;

select owneraddress
from Nashville.dbo.Sheet1$;



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Nashville.dbo.Sheet1$;

alter table nashville.dbo.sheet1$
add ownersplitaddress nvarchar(255);

update Nashville.dbo.Sheet1$
set ownersplitaddress = parsename(replace(owneraddress, ',', '.'),3);

alter table nashville.dbo.sheet1$
add ownersplitcity nvarchar(255);

update nashville.dbo.Sheet1$
set ownersplitcity = parsename(replace(owneraddress, ',', '.'), 2);


alter table nashville.dbo.sheet1$
add ownersplitState nvarchar(255);

update Nashville.dbo.Sheet1$
set ownersplitstate = parsename(replace(owneraddress, ',', '.'), 1)

select *
from Nashville.dbo.Sheet1$;

--------------------------------------------------------------------------------------------------------

--  Lets change Y for Yes and N for No

select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville.dbo.Sheet1$
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when soldasvacant = 'Y' THEN 'YES'
	when SoldAsVacant = 'N' THEN 'no'
	else SoldAsVacant
	END
from Nashville.dbo.Sheet1$;



update Nashville.dbo.Sheet1$
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'YES'
	when SoldAsVacant = 'N' THEN 'NO'
	Else SoldAsVacant
	END


----------------------------------------------------------------------------------------------------------

-- Lets remove the duplicates

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

From Nashville.dbo.Sheet1$
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From Nashville.dbo.Sheet1$;

------------------------------------------------------------------------------------------

-- Lets delete unused columns

select *
from Nashville.dbo.Sheet1$;

alter table nashville.dbo.sheet1$
drop column owneraddress, taxDistrict, propertyaddress, saledate;
