use AdventureWorks2012;
go

--a) Create a Person.CountryRegionHst table that will store the change information in the Person.CountryRegion table.
--Mandatory fields that must be present in the table: 
--ID - primary key IDENTITY (1,1); 
--Action - the action taken (insert, update or delete); 
--ModifiedDate - date and time when the operation was performed; 
--SourceID is the primary key of the source table; 
--UserName - the name of the user who performed the operation. 
--Create other fields as you see fit.

create table Person.CountryRegionHst (
	ID int identity(1,1) primary key,
	Action nvarchar(6) not null check (Action in ('INSERT', 'UPDATE', 'DELETE')),
	ModifiedDate datetime not null default GETDATE(),
	SourceID nvarchar(3) not null,
	UserName nvarchar(100) not null default USER_NAME()
);
go

select * from Person.CountryRegionHst;
go

--b) Create three AFTER triggers for three INSERT, UPDATE, DELETE operations on Person.CountryRegion table. 
--Each trigger must populate the Person.CountryRegionHst table with the type of operation in the Action field.

create trigger Person.CountryRegion_INSERT
on Person.CountryRegion
after insert 
as insert into Person.CountryRegionHst (
	Action,
	SourceID)
values (
	'INSERT',
	(select CountryRegionCode 
	from inserted)
);	
go

create trigger Person.CountryRegion_UPDATE
on Person.CountryRegion
after update 
as insert into Person.CountryRegionHst (
	Action,
	SourceID)
values (
	'UPDATE',
	(select CountryRegionCode 
	from inserted)
);
go

create trigger Person.CountryRegion_DELETE
on Person.CountryRegion
after delete 
as insert into Person.CountryRegionHst (
	Action,
	SourceID)
values (
	'DELETE',
	(select CountryRegionCode 
	from deleted)
);
go

--c) Create a VIEW displaying all the fields of the Person.CountryRegion table. 
--Make it impossible to view the source code of the view.

create view Person.CountryRegionView
with encryption
as (select * from Person.CountryRegion);
go

--d) Insert a new line into Person.CountryRegion through the view. 
--Update the inserted row. Delete the inserted line. 
--Make sure all three operations are mapped to Person.CountryRegionHst.

insert into Person.CountryRegionView (
	CountryRegionCode, 
	Name, 
	ModifiedDate)
values (
	'MM',
	'SomeName',
	getdate()
);
go

update Person.CountryRegionView
set Name = 'NewName'
where CountryRegionCode = 'MM' ;
go

delete Person.CountryRegionView
where CountryRegionCode = 'MM';
go

select * from Person.CountryRegionHst;
go