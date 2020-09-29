USE AdventureWorks2012;
GO

--создайте таблицу dbo.Address с такой же структурой как Person.Address, 
--кроме полей geography, uniqueidentifier, не включа€ индексы, ограничени€ и триггеры;

CREATE TABLE dbo.Address(
	AddressID int not null,
	AddressLine1 nvarchar(60) not null,
	AddressLine2 nvarchar(60) null,
	City nvarchar(30) not null,
	StateProvinceID int not null,
	PostalCode nvarchar(15) not null,
	ModifiedDate datetime not null
);
GO

--использу€ инструкцию ALTER TABLE, добавьте в таблицу dbo.Address новое поле ID с типом данных INT, 
--имеющее свойство identity с начальным значением 1 и приращением 1. 
--—оздайте дл€ нового пол€ ID ограничение UNIQUE;

ALTER TABLE dbo.Address
ADD ID int IDENTITY(1, 1);
GO

ALTER TABLE dbo.Address
ADD UNIQUE (ID);
GO

--использу€ инструкцию ALTER TABLE, создайте дл€ таблицы dbo.Address ограничение 
--дл€ пол€ StateProvinceID, чтобы заполнить его можно было только нечетными числами;

ALTER TABLE dbo.Address
ADD CONSTRAINT CHECK_StateProvinceID
CHECK (StateProvinceID % 2 = 1);
GO

--использу€ инструкцию ALTER TABLE, создайте дл€ таблицы dbo.Address ограничение DEFAULT
--дл€ пол€ AddressLine2, задайте значение по умолчанию СUnknownТ;

ALTER TABLE dbo.Address
ADD CONSTRAINT DEFAULT_AddressLine2
DEFAULT 'Unknown' FOR AddressLine2;
GO

--заполните новую таблицу данными из Person.Address. 
--¬ыберите дл€ вставки только те адреса, где значение пол€ Name из таблицы CountryRegion начинаетс€ на букву СаТ. 
--“акже исключите данные, где StateProvinceID содержит четные числа. 
--«аполните поле AddressLine2 значени€ми по умолчанию;

INSERT INTO dbo.Address(
	AddressID,
	AddressLine1,
	City,
	StateProvinceID,
	PostalCode,
	ModifiedDate
)
SELECT 
	Person.Address.AddressID,
	Person.Address.AddressLine1,
	Person.Address.City,
	Person.Address.StateProvinceID,
	Person.Address.PostalCode,
	Person.Address.ModifiedDate
FROM Person.Address
INNER JOIN Person.StateProvince
	ON Person.Address.StateProvinceID = Person.StateProvince.StateProvinceID
INNER JOIN Person.CountryRegion
	ON Person.StateProvince.CountryRegionCode = Person.CountryRegion.CountryRegionCode
WHERE Person.CountryRegion.Name LIKE 'a%' AND Person.StateProvince.StateProvinceID % 2 != 0;
GO
SELECT * FROM dbo.Address;
GO
--измените поле AddressLine2, запретив вставку null значений.

ALTER TABLE dbo.Address
ALTER COLUMN AddressLine2 nvarchar(60) not null;
GO