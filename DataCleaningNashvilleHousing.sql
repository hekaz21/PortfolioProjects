--Cleaning Data in SQL Queries
select *
from [Nashville Housing].dbo.NashvilleHousing

--Standarize Date Format

select SaleDateConverted, convert(date,saledate)
from [Nashville Housing].dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,saledate)

alter table NashvilleHousing 
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,saledate)


--Populate Propert Address Data

select *
from [Nashville Housing].dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing].dbo.NashvilleHousing a
join [Nashville Housing].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing].dbo.NashvilleHousing a
join [Nashville Housing].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




--Breaking out Address Into Individual Columns (address,City,State)


select PropertyAddress
from [Nashville Housing].dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


select
SUBSTRING(propertyaddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress)+1, len(propertyaddress)) as Address

from [Nashville Housing].dbo.NashvilleHousing

alter table NashvilleHousing 
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing 
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress)+1, len(propertyaddress))


select *
from [Nashville Housing].dbo.NashvilleHousing







select OwnerAddress
from [Nashville Housing].dbo.NashvilleHousing



select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from [Nashville Housing].dbo.NashvilleHousing


alter table NashvilleHousing 
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing 
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing 
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)






--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), COUNT (soldasvacant)
from [Nashville Housing].dbo.NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from [Nashville Housing].dbo.NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


--Remove Duplicates

with RowNumCTE as (
select *, 
	ROW_NUMBER() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from [Nashville Housing].dbo.NashvilleHousing
)
Delete
from RowNumCTE
where row_num > 1
--order by propertyaddress



--Delete Unused Columns


select *
from [Nashville Housing].dbo.NashvilleHousing

alter table [Nashville Housing].dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table [Nashville Housing].dbo.NashvilleHousing
drop column SaleDate
