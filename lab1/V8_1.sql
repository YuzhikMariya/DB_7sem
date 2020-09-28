USE master;
GO

CREATE DATABASE NewDatabase;
GO

USE NewDatabase;
GO

CREATE SCHEMA sales;
GO

CREATE SCHEMA persons;
GO

CREATE TABLE sales.Orders(OrderNum INT NULL);
GO

BACKUP DATABASE NewDatabase
TO DISK = 'D:\Doc\DB\lab1\Yuzhyk_DB.bak';
GO

USE master;
GO

DROP DATABASE NewDatabase;
GO

RESTORE DATABASE NewDatabase
FROM DISK = 'D:\Doc\DB\lab1\Yuzhyk_DB.bak';
GO