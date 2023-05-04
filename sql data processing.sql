--- view original data
select * from Housing.dbo.HousingTable


--- standardize data
--update HousingTable set SaleDate = convert(date, SaleDate)  ---not working

alter table HousingTable add NewSaleDate date;

update HousingTable set NewSaleDate = convert(date, SaleDate)

select NewSaleDate from HousingTable

--- Fill null property address
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from HousingTable a join HousingTable b on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from HousingTable a join HousingTable b on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--- split property address into street, city
 select
 substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) 
 as Address,
 substring(PropertyAddress, charindex(',', PropertyAddress) + 1, Len(PropertyAddress))
 as City
 from HousingTable

 alter table HousingTable
 add StreetAddress nvarchar(255);

 alter table HousingTable
 add City nvarchar(255);

 update HousingTable
 set PropertyStreet = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1);

 update HousingTable
 set PropertyCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, Len(PropertyAddress))

 select * from HousingTable


 --- split owner address
 alter table HousingTable
 add OwnerStreet nvarchar(255);

 alter table HousingTable
 add OwnerCity nvarchar(255);

 alter table HousingTable
 add OwnerState nvarchar(255);

 update HousingTable
 set OwnerStreet = parsename(replace(OwnerAddress, ',', '.'), 3);

 update HousingTable
 set OwnerCity = parsename(replace(OwnerAddress, ',', '.'), 2);

 update HousingTable
 set OwnerState = parsename(replace(OwnerAddress, ',', '.'), 1);

 select * from HousingTable


 --- convert y to yes n to no
select distinct(SoldAsVacant), count(SoldAsVacant)
from HousingTable
group by SoldAsVacant
order by 2

update HousingTable set SoldAsVacant = case 
	when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	end


--- remove duplicate
with CTE as (
select *,
	row_number() over (
	partition by ParcelID, PropertyAddress, SalePrice,
	SaleDate, LegalReference
	order by UniqueID) row_num
from HousingTable )
delete from CTE where row_num > 1

--- remove unwanted column
alter table HousingTable
drop column PropertyAddress, OwnerAddress