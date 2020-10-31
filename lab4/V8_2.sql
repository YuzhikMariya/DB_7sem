use AdventureWorks2012;
go

--a) Create a VIEW that displays data from the Person.CountryRegion and Sales.SalesTerritory tables. 
--Create a unique clustered index in the view on the TerritoryID field.

create view Person.CountryRegion_View
with schemabinding
as 
	(select  
		CR.CountryRegionCode,
		CR.Name as Country,
		ST.CostLastYear,
		ST.CostYTD,
		ST.[Group],
		ST.ModifiedDate,
		ST.Name,
		ST.rowguid,
		ST.SalesLastYear,
		ST.SalesYTD,
		ST.TerritoryID
	from Person.CountryRegion as CR inner join Sales.SalesTerritory as ST
	on CR.CountryRegionCode = ST.CountryRegionCode);
go

create unique clustered index IDX_TerritoryID
on Person.CountryRegion_View (TerritoryID);
go

--b) Create one INSTEAD OF trigger for the view for three INSERT, UPDATE, DELETE operations. 
--The trigger must perform the appropriate operations on the Person.CountryRegion and Sales.SalesTerritory tables.

create trigger Person.CountryRegion_INSTEADOFALL
on Person.CountryRegion_View
instead of insert, update, delete
as
begin
	if exists (select * from inserted)
	begin
		if not exists (
			select * from inserted as i inner join Person.CountryRegion_View as CRV
			on i.TerritoryID = CRV.TerritoryID)
		begin	
			insert into Person.CountryRegion
				(CountryRegionCode,
				Name,
				ModifiedDate)
			select 
				CountryRegionCode,
				Country,
				ModifiedDate
			from inserted	
						
			insert into Sales.SalesTerritory
				(CostLastYear,
				CostYTD,
				CountryRegionCode,
				[Group],
				ModifiedDate,
				Name,
				rowguid,
				SalesLastYear,
				SalesYTD)
			select 
				i.CostLastYear,
				i.CostYTD,
				i.CountryRegionCode,
				i.[Group],
				i.ModifiedDate,
				i.Name,
				i.rowguid,
				i.SalesLastYear,
				i.SalesYTD
			from inserted as i 
			inner join Person.CountryRegion as CR 
			on i.CountryRegionCode = CR.CountryRegionCode;			
		end
		else
		begin
			update Person.CountryRegion
			set
				CountryRegionCode = inserted.CountryRegionCode,
				Name = inserted.Country,
				ModifiedDate = inserted.ModifiedDate
			from inserted
			where inserted.CountryRegionCode = Person.CountryRegion.CountryRegionCode;

			update Sales.SalesTerritory
			set
				CostLastYear = inserted.CostLastYear,
				CostYTD = inserted.CostYTD,
				CountryRegionCode = inserted.CountryRegionCode,
				[Group] = inserted.[Group],
				ModifiedDate = inserted.ModifiedDate,
				Name = inserted.Name,
				rowguid = inserted.rowguid,
				SalesLastYear = inserted.SalesLastYear,
				SalesYTD = inserted.SalesYTD
			from inserted
			where inserted.TerritoryID = Sales.SalesTerritory.TerritoryID;
		end
	end
	if exists (select * from deleted) and not exists (select * from inserted)
	begin
		delete Sales.SalesTerritory
		where TerritoryID in (select TerritoryID from deleted)
		
		delete Person.CountryRegion
		where CountryRegionCode in (select CountryRegionCode from deleted) and CountryRegionCode not in (select CountryRegionCode from Sales.SalesTerritory)
	end
end;
go

--c) Insert a new row into the view, specifying new data for CountryRegion and SalesTerritory. 
--The trigger should add new rows to the Person.CountryRegion and Sales.SalesTerritory tables. 
--Update the inserted rows through the view. Delete the lines.

insert into Person.CountryRegion_View (
	CostLastYear,
	CostYTD,
	Country,
	CountryRegionCode,
	[Group],
	ModifiedDate,
	Name,
	rowguid,
	SalesLastYear,
	SalesYTD)
values (0, 0, 'Abcabcabc', 'MM', 'Abcabcabc', getdate(), 'Abcabcabc', newid(), 12345678, 65412378);
go

select * from Person.CountryRegion
where Person.CountryRegion.CountryRegionCode = 'MM';
go

select * from Sales.SalesTerritory
where Sales.SalesTerritory.CountryRegionCode = 'MM';
go

update Person.CountryRegion_View
set 
	CostLastYear = 2,
	Country = 'Abcabcabc'
where CountryRegionCode = 'MM';
go

select * from Person.CountryRegion
where Person.CountryRegion.CountryRegionCode = 'MM';
go

select * from Sales.SalesTerritory
where Sales.SalesTerritory.CountryRegionCode = 'MM';
go

delete Person.CountryRegion_View
where CountryRegionCode = 'MM';
go

select * from Person.CountryRegion;
go

select * from Sales.SalesTerritory;
go