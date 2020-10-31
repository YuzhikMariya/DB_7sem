use AdventureWorks2012;
go

--a) Add a 100-character nvarchar field PersonName to the dbo.Address table;
alter table dbo.Address
add PersonName nvarchar(100);
go

--b) declare a table variable with the same structure as dbo.Address and fill it 
--with data from dbo.Address, where StateProvinceID = 77. 
--Fill the AddressLine2 field with the values ​​from CountryRegionCode of Person.CountryRegion table,
--Name of Person.StateProvince table, and City from Address. Separate values ​​with commas;
declare @NewAddress table (
	AddressID int not null,
	AddressLine1 nvarchar(60) null,
	AddressLine2 nvarchar(60) not null,
	City nvarchar(30) null,
	StateProvinceID int null,
	PostalCode nvarchar(15) null,
	ModifiedDate datetime null,
	ID int identity(1,1) UNIQUE not null,
	PersonName nvarchar(100) null
);

insert into @NewAddress
	(AddressID,
	AddressLine1,	
	AddressLine2,
	City,
	StateProvinceID,
	PostalCode,
	ModifiedDate)
select 
	AddressID,
	AddressLine1,
	(CONCAT(
		(select CR.CountryRegionCode 
		from Person.CountryRegion as CR 
		inner join Person.StateProvince as SP 
		on CR.CountryRegionCode = SP.CountryRegionCode 
		inner join Person.Address as AD
		on SP.StateProvinceID = AD.StateProvinceID
		where AD.AddressID = A.AddressID),', ', 
		(select SP.Name 
		from Person.StateProvince as SP 
		inner join Person.Address as AD 
		on SP.StateProvinceID = AD.StateProvinceID
		where AD.AddressID = A.AddressID), 
	', ', City)),
	City,
	StateProvinceID,
	PostalCode,
	ModifiedDate
from dbo.Address as A
where StateProvinceID = 77;

--c) update the AddressLine2 field in dbo.Address with the data from the table variable. 
--Also update the data in the PersonName field with the data from Person.Person 
--by concatenating the values ​​of the FirstName and LastName fields;
update dbo.Address
set AddressLine2 = newA.AddressLine2 
from @NewAddress as newA;
go

update dbo.Address 
set PersonName = P.FirstName + ' ' + P.LastName 
from Person.Person as P 
inner join Person.BusinessEntityAddress as B 
on B.BusinessEntityID = P.BusinessEntityID 
where B.AddressID = dbo.Address.AddressID;
go


--d) remove the data from dbo.Address that is of type 'Main Office' from the Person.AddressType table;
delete dbo.Address 
from dbo.Address as A 
inner join Person.BusinessEntityAddress as B
on A.AddressID = B.AddressID 
inner join Person.AddressType as AT
on B.AddressTypeID = AT.AddressTypeID
where AT.Name = 'Main Office';
go

--e) remove the PersonName field from the table, remove all created constraints and default values;
SELECT * FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Address';

alter table dbo.Address 
drop column PersonName;
go

alter table dbo.Address 
drop constraint UQ__Address__3214EC2653EF0ABD;
go

alter table dbo.Address 
drop constraint CHECK_StateProvinceID;
go

alter table dbo.Address 
drop constraint DEFAULT_AddressLine2;
go

--f) delete the dbo.Address table.
drop table dbo.Address
go