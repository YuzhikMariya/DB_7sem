--a) run the code generated in the second activity of the second lab. 
--Add the AccountNumber NVARCHAR (15) and MaxPrice MONEY fields to the dbo.Address table. 
--Also create a calculated field AccountID in the table, which will add the ‘ID’ prefix 
--to the value in the AccountNumber field.
alter table dbo.Address
add AccountNumber nvarchar(15),
	MaxPrice money,
	AccountID as 'ID' + AccountNumber;
go

select * from dbo.Address;
go

--b) create a temporary table #Address, with a primary key on the ID field. 
--The temporary table must include all the fields in the dbo.Address table 
--except for the AccountID field.
create table dbo.#Address(
	AddressID int not null,
	AddressLine1 nvarchar(60),
	AddressLine2 nvarchar(60) not null ,
	City nvarchar(30),
	StateProvinceID int,
	PostalCode nvarchar(15),
	ModifiedDate datetime,
	ID int identity(1, 1) primary key,
	AccountNumber nvarchar(15),
	MaxPrice money
);
go

--c) fill the temp table with data from dbo.Address. 
--Fill in the AccountNumber field with the data from the Purchasing.Vendor table. 
--Determine the maximum price of the product (StandardPrice) supplied by each supplier (BusinessEntityID) 
--in the Purchasing.ProductVendor table and fill in the MaxPrice field with these values. 
--Calculate the maximum price in the Common Table Expression (CTE).
with Address_CTE as
(select
	A.AddressID,
	A.AddressLine1,
	A.AddressLine2,	
	A.City,
	A.StateProvinceID,
	A.PostalCode,
	A.ModifiedDate,
	(select AccountNumber
	from Purchasing.Vendor as V 
	inner join Person.BusinessEntityAddress as B
	on V.BusinessEntityID = B.BusinessEntityID	
	where A.AddressID = B.AddressID) as AccountNumber,
	(select MAX(StandardPrice) 
	from Purchasing.ProductVendor as V 
	inner join Person.BusinessEntityAddress as B
	on V.BusinessEntityID = B.BusinessEntityID	
	group by V.BusinessEntityID, B.AddressID
	having AddressID = A.AddressID) as MaxPrice
from dbo.Address as A)

insert into dbo.#Address (
	AddressID,
	AddressLine1,
	AddressLine2,	
	City,
	StateProvinceID,
	PostalCode,
	ModifiedDate,
	AccountNumber,
	MaxPrice
) select 
	AddressID,
	AddressLine1,
	AddressLine2,	
	City,
	StateProvinceID,
	PostalCode,
	ModifiedDate,
	AccountNumber,
	MaxPrice
from Address_CTE;

select * from dbo.Address;
go

--d) remove one row from dbo.Address table (where ID = 293)
delete from dbo.Address where ID = 293;
go

--e) write a Merge expression using dbo.Address as target and temporary table as source. 
--Use ID to link target and source. 
--Update the AccountNumber and MaxPrice fields if an entry is present in source and target. 
--If the row is present in the temporary table but does not exist in target, add the row to dbo.Address. 
--If there is a row in dbo.Address that does not exist in the temporary table, remove the row from dbo.Address.
merge dbo.Address as target 
using dbo.#Address as source
on target.ID = source.ID
when matched 
then update set
	AccountNumber = source.AccountNumber,
	MaxPrice = source.MaxPrice
when not matched  by target
then insert (
		AddressID,
		AddressLine1,
		AddressLine2,	
		City,
		StateProvinceID,
		PostalCode,
		ModifiedDate,
		AccountNumber,
		MaxPrice)
	values (
		source.AddressID,
		source.AddressLine1,
		source.AddressLine2,	
		source.City,
		source.StateProvinceID,
		source.PostalCode,
		source.ModifiedDate,
		source.AccountNumber,
		source.MaxPrice)
when not matched  by source
then delete;
go

select * from dbo.Address;
go
