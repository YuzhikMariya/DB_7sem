USE AdventureWorks2012;
GO

--Вывести на экран список сотрудников которые подавали резюме при трудоустройстве.

SELECT Employee.BusinessEntityID, OrganizationLevel, JobTitle, JobCandidateID, Resume
FROM HumanResources.Employee
INNER JOIN HumanResources.JobCandidate
ON Employee.BusinessEntityID = JobCandidate.BusinessEntityID;
GO

--Вывести на экран названия отделов, в которых работает более 10-ти сотрудников

SELECT Department.DepartmentID, Name, COUNT(EmployeeDepartmentHistory.BusinessEntityID) AS EmpCount
FROM HumanResources.Department
INNER JOIN HumanResources.EmployeeDepartmentHistory
ON Department.DepartmentID = EmployeeDepartmentHistory.DepartmentID
INNER JOIN HumanResources.Employee
ON EmployeeDepartmentHistory.BusinessEntityID = Employee.BusinessEntityID
GROUP BY Department.DepartmentID, Department.Name
HAVING COUNT(EmployeeDepartmentHistory.BusinessEntityID) > 10;
GO

--Вывести на экран накопительную сумму часов отпуска по причине болезни (SickLeaveHours)
--в рамках каждого отдела. Сумма должна накапливаться по мере трудоустройства сотрудников (HireDate).

SELECT Name, HireDate, SickLeaveHours,
(	SELECT SUM(SickLeaveHours) 
	FROM HumanResources.Department d
	INNER JOIN HumanResources.EmployeeDepartmentHistory ed
		ON d.DepartmentID = ed.DepartmentID
	INNER JOIN HumanResources.Employee e
		ON ed.BusinessEntityID = e.BusinessEntityID
	WHERE DATEDIFF(mi, e.HireDate, Employee.HireDate) >= 0
	GROUP BY Name
		HAVING d.Name = Department.Name
) 
AS AccumulativeSum
FROM HumanResources.Department
INNER JOIN HumanResources.EmployeeDepartmentHistory
ON Department.DepartmentID = EmployeeDepartmentHistory.DepartmentID
INNER JOIN HumanResources.Employee
ON EmployeeDepartmentHistory.BusinessEntityID = Employee.BusinessEntityID
GROUP BY Name, HireDate, SickLeaveHours;
GO