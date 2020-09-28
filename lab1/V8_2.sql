USE AdventureWorks2012;
GO

SELECT BusinessEntityID, BirthDate, MaritalStatus, Gender, HireDate
FROM HumanResources.Employee
WHERE YEAR(BirthDate) <= 1960 AND MaritalStatus = 'S';
GO

SELECT BusinessEntityID, JobTitle, BirthDate, Gender, HireDate
FROM HumanResources.Employee
WHERE JobTitle = 'Design Engineer'
ORDER BY HireDate DESC;
GO

SELECT BusinessEntityID, DepartmentID, StartDate, EndDate, 
DATEDIFF(YEAR, StartDate, ISNULL(EndDate, CURRENT_TIMESTAMP)) AS YearsWorked
FROM HumanResources.EmployeeDepartmentHistory
WHERE DepartmentID = 1;
GO
