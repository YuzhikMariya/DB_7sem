USE AdventureWorks2012;
GO

--�������� ������� dbo.Address � ����� �� ���������� ��� Person.Address, 
--����� ����� geography, uniqueidentifier, �� ������� �������, ����������� � ��������;

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

--��������� ���������� ALTER TABLE, �������� � ������� dbo.Address ����� ���� ID � ����� ������ INT, 
--������� �������� identity � ��������� ��������� 1 � ����������� 1. 
--�������� ��� ������ ���� ID ����������� UNIQUE;

ALTER TABLE dbo.Address
ADD ID int IDENTITY(1, 1);
GO

ALTER TABLE dbo.Address
ADD UNIQUE (ID);
GO

--��������� ���������� ALTER TABLE, �������� ��� ������� dbo.Address ����������� 
--��� ���� StateProvinceID, ����� ��������� ��� ����� ���� ������ ��������� �������;

ALTER TABLE dbo.Address
ADD CONSTRAINT CHECK_StateProvinceID
CHECK (StateProvinceID % 2 = 1);
GO

--��������� ���������� ALTER TABLE, �������� ��� ������� dbo.Address ����������� DEFAULT
--��� ���� AddressLine2, ������� �������� �� ��������� �Unknown�;

ALTER TABLE dbo.Address
ADD CONSTRAINT DEFAULT_AddressLine2
DEFAULT 'Unknown' FOR AddressLine2;
GO

--��������� ����� ������� ������� �� Person.Address. 
--�������� ��� ������� ������ �� ������, ��� �������� ���� Name �� ������� CountryRegion ���������� �� ����� ���. 
--����� ��������� ������, ��� StateProvinceID �������� ������ �����. 
--��������� ���� AddressLine2 ���������� �� ���������;

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
--�������� ���� AddressLine2, �������� ������� null ��������.

ALTER TABLE dbo.Address
ALTER COLUMN AddressLine2 nvarchar(60) not null;
GO