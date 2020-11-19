use AdventureWorks2012;
go

--Create scalar-valued function

create function Production.ProductsCount (@id int)
returns int 
as
begin 
	declare @res int
	set @res = (
		select count(ProductID) 
		from Production.Product 
		where ProductSubcategoryID = @id
	)
	return @res
end;
go

--Create inline table-valued function

create function Production.ExpensiveProductsCount (@id int)
returns table 
as
return (
	select ProductSubcategoryID, ProductID 
	from Production.Product 
	where ProductSubcategoryID = @id and StandardCost > 1000
);
go

--Call functions using CROSS APPLY and OUTER APPLY.

select * 
from Production.Product cross apply Production.ExpensiveProductsCount(ProductSubcategoryID) as E
order by E.ProductSubcategoryID;

select * 
from Production.Product outer apply Production.ExpensiveProductsCount(ProductSubcategoryID) as E
order by E.ProductSubcategoryID;
go

--Create multistatement table-valued function

create function Production.ExpensiveProductsCount2(@id int)
returns @expensiveProducts table (
	ProductSubcategoryID int null,
	ProductID  int not null
)
as
begin
	insert into @expensiveProducts
	select ProductSubcategoryID, ProductID 
	from Production.Product 
	where ProductSubcategoryID = @id and StandardCost > 1000
	return
end;
go