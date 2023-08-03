--Alex The Analyst Guided Portfolio Project 3 - Data Cleaning In SQL
--Downloaded Excel file from Alex's Github site: 
--https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqbTFucXhVNEZzZlNacmhjRTdfRGF1Wmsyd181UXxBQ3Jtc0tsSURsNnAxVlFZTUl6d1JVZjlHS25tMTdLZGFHSl9ISXcyNjNfQzIyNlJkV1hiX3F0VnlacVhqZE9DT3JONktqTmxzNTRvRHF5VkQyOUxoU01sYU8zV0tyQnBab1N2UmdkVGZfLWkycnBfOEZnWHdFaw&q=https%3A%2F%2Fgithub.com%2FAlexTheAnalyst%2FPortfolioProjects%2Fblob%2Fmain%2FNashville%2520Housing%2520Data%2520for%2520Data%2520Cleaning.xlsx&v=8rO7ztF4NtU
--Opened file in Excel, then converted Excel file to CSV file because Azure Data Studio cannot
--import an Excel file.  Have not yet discovered an Azure Extension to get this done.
--Imported CSV into Azure Data Studio and selected NVARCHAR(50) for all data types, except for one
--NVARCHAR(100) which I left alone, becasue trying to clean this data in Excel was going to be 
--excruciatingly time consuming.
--Created new table "dbo.NashvilleHousing for use in this project

--Previewed TOP (1000) rows:
SELECT TOP (1000) [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfoiloProject].[dbo].[NashvilleHousing]; 

/*

Cleaning Data Using SQL Queries

*/

SELECT *
FROM dbo.NashvilleHousing;

--56,477 rows of data.  Apparently query results do NOT include header row.  Cool!

----------------------------------------------------------------------------------

--Standardize Date Format
--Nothing to do here.  Dates look pretty standard to me:  YYYY-MM-DD.  No timestamp showed up
--during my upload.  Nothing else to do.  Moving on...

/* NOTE:  None of the following code is required:
Added new column:
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

--Verified it worked:
SELECT 
  SaleDate, 
  SaleDateConverted
FROM dbo.NashvilleHousing;

--Tried to an update that did NOT WORK
UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate,1);

--Error message follows
Started executing query at Line 60
Msg 241, Level 16, State 1, Line 1
Conversion failed when converting date and/or time from character string.
Total execution time: 00:00:00.042

--Tried again, but still no love....
UPDATE NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS DATE);

--Another error message
Started executing query at Line 72
Msg 241, Level 16, State 1, Line 1
Conversion failed when converting date and/or time from character string.
Total execution time: 00:00:00.019

*/

--------------------------------------------------------------------------

--Populate Property Address data

--Taking a quick look at current property address format
SELECT TOP 10
PropertyAddress
FROM dbo.NashvilleHousing;

--Checking for NULL property addresses

SELECT *
FROM dbo.NashvilleHousing
WHERE PropertyAddress IS NULL;

--Yup, 29 NULL property addresses...
--Now let's look at the same data without WHERE clause and adding an ORDER BY clause

SELECT *
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID ASC;

--Duplicate PARCEL ID's indicate the same address, so...

SELECT 
a.ParcelID, 
a.PropertyAddress,
b.ParcelID,
b.PropertyAddress
--ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

--Now let's see what happens when adding an "ISNULL" section to the SELECT statement...

SELECT 
a.ParcelID, 
a.PropertyAddress,
b.ParcelID,
b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

--Great!  This worked and added the necessary data under that desired conditions.
--Now it's time to update the table to eliminate those pesky NULL property addresses

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.propertyaddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

--Looks like 29 rows were affected, let's check...

SELECT 
a.ParcelID, 
a.PropertyAddress,
b.ParcelID,
b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

--No records returned, script worked just fine!
--Moving on to "Breaking out Address into individual colums (Address, City, State)"

SELECT 
PropertyAddress
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL;
--ORDER BY ParcelID ASC;

--Now for some more magic...
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM dbo.NashvilleHousing;

--Above script worked perfectly... Now for another column add & update for each new column.

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

--Final verification for this set of new address columns

SELECT *
FROM dbo.NashvilleHousing;

--Confirmed, new columns inserted with data :-)
--Now for Owner Address splits.....

SELECT OwnerAddress
FROM dbo.NashvilleHousing;

--Contains street address, city, and state all in one field.  Problematic to say the least...
--A little parsing anyone?

SELECT 
PARSENAME(OwnerAddress,1)
FROM dbo.NashvilleHousing;

--So far, it's the same data as before.  Moving on...

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
FROM dbo.NashvilleHousing;

--Seems to be parsing from the right to the left, then displaying the results left-to-right.  Interesting.
--WAY simpler than using "SUBSTRING" syntax (Just like Alex said it would be - Thanks!)
--Ordering fix is so simple it's almost unbelieveable...

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM dbo.NashvilleHousing;

--NOW everything is parsed into the correct order.  WOW!  How cool is that?!
--Gotta add 3 new columns & data to the NashvilleHousing table...

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1);

--The six sets of scripts ran flawlessly.  Time to verify...

SELECT
OwnerSplitAddress
,OwnerSplitCity
,OwnerSplitState
FROM dbo.NashvilleHousing;

--Perfect!  Moving on to Changing errant Y and N to Yes and No in "Sold As Vacant" field
--Here we go...

SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 ASC;

--Easy method to see the non-standard entries...
--Now for the first part of the fix...

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
      END
FROM dbo.NashvilleHousing;

--Update dbo.NashvilleHousing time...

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
      END

--Time to verify this update...

SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 ASC;

--Yup, it worked!  No more Y's or N's.  Only "Yes" and "No" - GREAT!
--Next up, "Removing Duplicates" <<Normally, do this in a Temp Table>>
--Query First

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
      PARTITION BY ParcelID,
                   PropertyAddress,
                   SalePrice,
                   SaleDate,
                   LegalReference
                   ORDER BY
                   UniqueID
    ) row_num
FROM dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

--This part worked well... Now for the scary part....

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
      PARTITION BY ParcelID,
                   PropertyAddress,
                   SalePrice,
                   SaleDate,
                   LegalReference
                   ORDER BY
                   UniqueID
    ) row_num
FROM dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress;

--Seems like 104 rows were deleted.  Now for a verification...

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
      PARTITION BY ParcelID,
                   PropertyAddress,
                   SalePrice,
                   SaleDate,
                   LegalReference
                   ORDER BY
                   UniqueID
    ) row_num
FROM dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

--Success!  No more duplicate rows!  Moving on...
--Delete Unused columns...
--First, let's take another look at the dataset to identify unused columns...
--NOTE:  Do NOT do this to the raw data, someone will be UNHAPPY eventually.  You've been warned!

SELECT *
FROM dbo.NashvilleHousing;

--Make sure you have a back-up copy of your data before doing this!

ALTER TABLE dbo.NashvilleHousing
  DROP COLUMN OwnerAddress, PropertyAddress
GO

--Verify it worked

SELECT *
FROM dbo.NashvilleHousing;

--Yup, OwnerAddress & PropertyAddress columns are now gone.  Quick, save everything!  We're done!
--NOTE:  I didn't even attempt Alex's optional ETL scripts.