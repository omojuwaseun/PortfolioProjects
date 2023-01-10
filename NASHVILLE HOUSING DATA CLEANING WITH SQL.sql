-- * cleaning data in sql queries


--1
select * 
from portfolioproject.dbo.NASHVILLEHOUSING

--  2 standardize date format

select SaleDate
from portfolioproject.dbo.NASHVILLEHOUSING
 
 -- method 1 for updating the date format
--update NASHVILLEHOUSING
--set SaleDate = convert(Date,SaleDate)

-- method 2 to update the date format but we're using this instead
-- we are adding a new column saledateconverted for the saledate formmating 
alter table NASHVILLEHOUSING
ADD SaleDateConverted date;

update NASHVILLEHOUSING
set SaleDateConverted = convert(date,Saledate)

select SaleDateConverted,convert(Date,saleDate) 
from portfolioproject.dbo.NASHVILLEHOUSING


-- 3 populating the property address

select * 
from portfolioproject.dbo.NASHVILLEHOUSING
--where PropertyAddress is null
order by ParcelID

select  a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolioproject.dbo.NASHVILLEHOUSING a
join portfolioproject.dbo.NASHVILLEHOUSING b
	on a.ParcelID = b.ParcelID
		and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolioproject.dbo.NASHVILLEHOUSING a
join portfolioproject.dbo.NASHVILLEHOUSING b
	on a.ParcelID = b.ParcelID
		and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

-- to check if the query worked 
select PropertyAddress
from portfolioproject.dbo.NASHVILLEHOUSING
where PropertyAddress is null

-- 4  Breaking out Address into Individual Columns (Address, City, State) because they are all clustered

select PropertyAddress
from portfolioproject.dbo.NASHVILLEHOUSING


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from portfolioproject.dbo.NASHVILLEHOUSING

-- creating a new column for address and city 

alter table NASHVILLEHOUSING
ADD PropertySplitAddress Nvarchar(255);

update NASHVILLEHOUSING
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 )

alter table NASHVILLEHOUSING
ADD PropertySplitCity Nvarchar(255);

update NASHVILLEHOUSING
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))


select *
from portfolioproject.dbo.NASHVILLEHOUSING 


-- 5 breaking up the owner address into address and city

select OwnerAddress
from portfolioproject.dbo.NASHVILLEHOUSING 

select
PARSENAME(Replace(ownerAddress,',','.'),3)
,PARSENAME(Replace(ownerAddress,',','.'),2)
,PARSENAME(Replace(ownerAddress,',','.'),1)
from portfolioproject.dbo.NASHVILLEHOUSING 

-- creating columns for the state city and address 
alter table NASHVILLEHOUSING
ADD OwnerSplitAddress Nvarchar(255)

update NASHVILLEHOUSING
set  OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

alter table NASHVILLEHOUSING
ADD  OwnerSplitCity  Nvarchar(255)

update NASHVILLEHOUSING
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)


alter table NASHVILLEHOUSING
ADD OwnerSplitState  Nvarchar(255)

update NASHVILLEHOUSING
set  OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

select *
from portfolioproject.dbo.NASHVILLEHOUSING 


-- 6 Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from portfolioproject.dbo.NASHVILLEHOUSING 
group by SoldAsVacant
order by 2 


select  SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end 
from portfolioproject.dbo.NASHVILLEHOUSING


update  NASHVILLEHOUSING
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end 
	 

--  7 remove duplicates using CTE 
with RowNumCTE AS(
select *,
	ROW_NUMBER() over (
	partition by ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 Legalreference
				 Order by 
				 UniqueId
				 ) row_num
from portfolioproject.dbo.NASHVILLEHOUSING 
--order by ParcelID
)
-- lets check what we just did
select *  
from RowNumCTE
where row_num > 1
--order by PropertyAddress



-- deleting unused columns

select *
from portfolioproject.dbo.NASHVILLEHOUSING

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

