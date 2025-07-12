-- 01_Basic_Queries.sql

USE AdventureWorks2012;

-- All employee details
SELECT * FROM [HumanResources].[Employee];

-- Specific columns
SELECT [BusinessEntityID],[JobTitle],[MaritalStatus],[Gender],[SickLeaveHours],[SalariedFlag]
FROM [HumanResources].[Employee];

-- Male employees
SELECT [BusinessEntityID], [JobTitle], [MaritalStatus], [Gender], [SickLeaveHours], [SalariedFlag]
FROM [HumanResources].[Employee]
WHERE [Gender] = 'M';

-- Married male employees with < 30 sick leave hours
SELECT [BusinessEntityID], [JobTitle], [MaritalStatus], [Gender], [SickLeaveHours]
FROM [HumanResources].[Employee]
WHERE [Gender] = 'M' AND [MaritalStatus] = 'M' AND [SickLeaveHours] < 30;

-- Female employees with > 50 vacation hours
SELECT [BusinessEntityID], [VacationHours], [JobTitle], [Gender]
FROM HumanResources.Employee 
WHERE Gender = 'F' AND [VacationHours] > 50;

-- Non-female employees
SELECT [BusinessEntityID], [VacationHours], [JobTitle], [Gender]
FROM [HumanResources].[Employee]
WHERE [Gender] <> 'F';

-- Filter by multiple roles
SELECT * FROM [HumanResources].[Employee]
WHERE [JobTitle] IN (
    'Research and Development Manager', 
    'Production Technician - WC60',
    'Production Supervisor - WC10',
    'Stocker',
    'Solomon'
);

-- Filter by roles, gender, marital status, sick leave
SELECT [BusinessEntityID], [VacationHours], [JobTitle], [Gender], [MaritalStatus]
FROM [HumanResources].[Employee]
WHERE [JobTitle] IN (
    'Research and Development Manager', 
    'Production Technician - WC60',
    'Production Supervisor - WC10',
    'Stocker'
) AND [Gender] = 'M'
  AND [MaritalStatus] = 'M' 
  AND [SickLeaveHours] >= 50;

-- Order by examples
SELECT * FROM [HumanResources].[Department] ORDER BY DepartmentID DESC;
SELECT * FROM [HumanResources].[Department] ORDER BY Name ASC;

-- Top and bottom records
SELECT * FROM [HumanResources].[EmployeePayHistory];
SELECT TOP 10 * FROM [HumanResources].[EmployeePayHistory] ORDER BY BusinessEntityID DESC;

-- 02_Logical_Operators.sql

USE AdventureWorks2012;

-- LIKE examples
SELECT * FROM [HumanResources].[Employee] WHERE NationalIDNumber LIKE '48%';
SELECT * FROM [HumanResources].[Employee] WHERE JobTitle LIKE '%ENGINEER';
SELECT * FROM [HumanResources].[Employee] WHERE JobTitle LIKE '%DESIGN%';
SELECT * FROM [HumanResources].[Employee] WHERE NationalIDNumber NOT LIKE '48%';

-- NOT IN example
SELECT * FROM [HumanResources].[Employee] WHERE BusinessEntityID NOT IN (12,13,14);

-- 03_Aggregates_and_Grouping.sql

USE AdventureWorks2012;

-- Count per Job Title
SELECT COUNT([JobTitle]) AS Employee_Count FROM [HumanResources].[Employee];

SELECT [JobTitle], COUNT([JobTitle]) AS Count
FROM [HumanResources].[Employee]
GROUP BY [JobTitle]
ORDER BY Count DESC;

-- Gender-based sick/vacation summary
SELECT [Gender], [MaritalStatus], SUM([SickLeaveHours]) AS Total_sick_hrs, SUM([VacationHours]) AS Total_Vac_hrs
FROM [HumanResources].[Employee]
GROUP BY [Gender], [MaritalStatus];

-- Gender count
SELECT [Gender], COUNT([Gender]) AS TOT_COUNT
FROM [HumanResources].[Employee]
GROUP BY [Gender];

-- Min/Max sick leave by gender
SELECT [Gender], MIN([SickLeaveHours]) AS MIN_SICK_HRS, MAX([SickLeaveHours]) AS MAX_SICK_HRS
FROM [HumanResources].[Employee]
GROUP BY [Gender];

-- Avg sick leave by gender
SELECT [Gender], AVG([SickLeaveHours]) AS AVG_HRS
FROM [HumanResources].[Employee]
GROUP BY [Gender];

-- Max sick leave by gender
SELECT [Gender], MAX([SickLeaveHours]) AS Max_Hrs
FROM [HumanResources].[Employee]
GROUP BY [Gender];

-- Avg sick hours for org level < 3
SELECT [OrganizationLevel], AVG([SickLeaveHours]) AS Avg_Sick_Hrs
FROM [HumanResources].[Employee]
WHERE [OrganizationLevel] < 3
GROUP BY [OrganizationLevel];

-- Gender count with HAVING
SELECT [Gender], COUNT([Gender]) AS gender_count
FROM [HumanResources].[Employee]
GROUP BY [Gender]
HAVING COUNT([Gender]) > 70;

-- 04_Date_Functions.sql

USE AdventureWorks2012;

-- Employees born in December
SELECT [BusinessEntityID], [JobTitle], [HireDate], [BirthDate], MONTH([BirthDate]) AS ACTUAL_MONTH_BIRTH
FROM [HumanResources].[Employee]
WHERE MONTH([BirthDate]) = 12;

-- Number of employees born each month
SELECT MONTH([BirthDate]) AS ACTUAL_MONTH_BIRTH, COUNT([BirthDate]) AS COUNT_OF_BIRTHDATE
FROM [HumanResources].[Employee]
GROUP BY MONTH([BirthDate])
ORDER BY COUNT([BirthDate]) DESC;

-- Day of week for employee birthdates
SELECT [BusinessEntityID], [JobTitle], DATENAME(WEEKDAY, [BirthDate]) AS Week_Name
FROM [HumanResources].[Employee];

-- Age calculation
SELECT [BusinessEntityID], [JobTitle], DATEDIFF(YEAR, [BirthDate], GETDATE()) AS AGE
FROM [HumanResources].[Employee];

-- Employees over 65 years and worked for 35
SELECT [BusinessEntityID], [JobTitle],
    DATEDIFF(YEAR, [HireDate], GETDATE()) AS WORK_YEAR,
    DATEDIFF(YEAR, [BirthDate], GETDATE()) AS AGE
FROM [HumanResources].[Employee]
WHERE DATEDIFF(YEAR, [HireDate], GETDATE()) = 35 AND DATEDIFF(YEAR, [BirthDate], GETDATE()) > 65;

-- DateAdd example
SELECT [BusinessEntityID], [JobTitle], DATEADD(YEAR, 35, [HireDate]) AS RETIREMENT_YEAR
FROM [HumanResources].[Employee];

--Employees Born Before 1990: Filter by Job Title or Male Gender
SELECT BusinessEntityID, JobTitle, VacationHours, SickLeaveHours, BirthDate, Gender, OrganizationLevel
FROM HumanResources.Employee
WHERE BirthDate < '1990-01-01' 
	AND
		(JobTitle IN ('Production Technician - WC40', 
					'Production Technician - WC30',
					'Production Technician - WC50')
)	OR
		(BirthDate < '1990-01-01'  AND Gender = 'M')
ORDER BY BirthDate desc;


-- 05_Joins.sql

USE AdventureWorks2012;

-- Inner join between Employee and Person
SELECT HE.[BusinessEntityID], HE.[JobTitle], PP.[FirstName], PP.[LastName]
FROM [HumanResources].[Employee] AS HE
INNER JOIN [Person].[Person] AS PP ON HE.[BusinessEntityID] = PP.[BusinessEntityID];

-- Inner join for products sold
SELECT DISTINCT SOD.[ProductID], PP.[Name], PP.[ListPrice], PP.[Color]
FROM [Production].[Product] AS PP
INNER JOIN [Sales].[SalesOrderDetail] AS SOD ON PP.[ProductID] = SOD.[ProductID];

-- Left join Sales and Product
SELECT SOD.[SalesOrderID], PP.[Name], SOD.[UnitPriceDiscount], SOD.[OrderQty]
FROM [Sales].[SalesOrderDetail] AS SOD
LEFT JOIN [Production].[Product] AS PP ON PP.[ProductID] = SOD.[ProductID];


--WHERE PP.[ProductSubcategoryID] IS NULL
SELECT *
FROM [Production].[Product];

SELECT *
FROM [Production].[ProductSubcategory];


SELECT PP.[ProductID],
		PP.[Name] AS Product_Name,
		PS.[Name] AS ProductSubCat_Name 
FROM  [Production].[Product] AS PP 
LEFT JOIN [Production].[ProductSubcategory]  AS PS
ON PS.[ProductSubcategoryID] = PP.[ProductSubcategoryID];

--WHERE PP.[ProductSubcategoryID] IS NOT NULL

SELECT PP.[ProductID],
		PP.[Name] AS Product_Name,
		PS.[Name] AS ProductSubCat_Name 
FROM  [Production].[Product] AS PP 
LEFT JOIN [Production].[ProductSubcategory]  AS PS
ON PS.[ProductSubcategoryID] = PP.[ProductSubcategoryID]
WHERE PP.[ProductSubcategoryID] IS NOT NULL;


-- Right join: All sales order details + product names
SELECT SOD.[SalesOrderID], SOD.[SalesOrderDetailID], SOD.[CarrierTrackingNumber], SOD.[OrderQty],
       SOD.[ProductID], PP.[Name], SOD.[SpecialOfferID], SOD.[UnitPrice], SOD.[UnitPriceDiscount], SOD.[LineTotal]
FROM [Production].[Product] AS PP
RIGHT JOIN [Sales].[SalesOrderDetail] AS SOD ON PP.[ProductID] = SOD.[ProductID];

-- Full join
SELECT PP.[ProductID], PP.[Name], PP.[FinishedGoodsFlag], PP.[Color], PP.[ListPrice],
       PP.[DaysToManufacture], SOD.[SalesOrderID], SOD.[OrderQty]
FROM [Production].[Product] AS PP
FULL JOIN [Sales].[SalesOrderDetail] AS SOD ON PP.[ProductID] = SOD.[ProductID];

-- 06_Subqueries_And_CTEs.sql

USE AdventureWorks2012;

-- SickLeave > average
SELECT [BusinessEntityID], [JobTitle], [HireDate], [SickLeaveHours]
FROM [HumanResources].[Employee]
WHERE [SickLeaveHours] > (SELECT AVG([SickLeaveHours]) FROM [HumanResources].[Employee]);

-- Married Production Technician - WC50 average sick leave
SELECT AVG([SickLeaveHours]) AS AVG_SCK_HRS__Production_Technician__WC50
FROM [HumanResources].[Employee]
WHERE [BusinessEntityID] IN (
    SELECT [BusinessEntityID]
    FROM [HumanResources].[Employee]
    WHERE [JobTitle] LIKE ('%Production Technician - WC50%') AND [MaritalStatus] = 'M'
);

-- VacationHours > average
SELECT * FROM [HumanResources].[Employee]
WHERE [VacationHours] > (SELECT AVG([VacationHours]) FROM [HumanResources].[Employee]);

-- CTE: Employees with sick leave > average
WITH AvgSickLeave AS (
    SELECT AVG(SickLeaveHours * 1.0) AS AvgSickLeaveHours
    FROM HumanResources.Employee
)
SELECT e.BusinessEntityID, e.JobTitle, e.SickLeaveHours
FROM HumanResources.Employee e
CROSS JOIN AvgSickLeave
WHERE e.SickLeaveHours > AvgSickLeave.AvgSickLeaveHours;

-- 07_Unions_Views.sql

USE AdventureWorks2012;

-- UNION examples
SELECT * FROM [HumanResources].[Employee]
UNION
SELECT * FROM [HumanResources].[Employee];

SELECT * FROM [HumanResources].[Employee]
UNION ALL
SELECT * FROM [HumanResources].[Employee];

-- INTERSECT: Products sold
SELECT [ProductID] FROM [Production].[Product]
INTERSECT
SELECT [ProductID] FROM [Sales].[SalesOrderDetail];

-- Products sold at least once
SELECT [ProductID], [Name]
FROM [Production].[Product]
WHERE [ProductID] IN (
    SELECT [ProductID] FROM [Production].[Product]
    INTERSECT
    SELECT [ProductID] FROM [Sales].[SalesOrderDetail]
);

-- EXCEPT: Products never sold
SELECT [ProductID] FROM [Production].[Product]
EXCEPT
SELECT [ProductID] FROM [Sales].[SalesOrderDetail];

-- View
CREATE VIEW transaction_details AS
SELECT SOD.[SalesOrderID], SOD.[SalesOrderDetailID], SOD.[CarrierTrackingNumber], SOD.[OrderQty],
       SOD.[ProductID], PP.[Name], SOD.[SpecialOfferID], SOD.[UnitPrice], SOD.[UnitPriceDiscount], SOD.[LineTotal]
FROM [Production].[Product] AS PP
RIGHT JOIN [Sales].[SalesOrderDetail] AS SOD ON PP.[ProductID] = SOD.[ProductID];

-- 08_Table_Creation_And_Alter.sql

USE AdventureWorks2012;

-- Create Table
CREATE TABLE Preps_ng (
    ID INT IDENTITY(1,1) NOT NULL,
    Student_id VARCHAR(255) NOT NULL,
    Name VARCHAR(255),
    Mobile_number INT,
    Gender VARCHAR(255),
    Date_Created DATETIME NOT NULL,
    Fee MONEY,
    Date_Of_Birth DATE
);

-- Insert
INSERT INTO Preps_ng (Student_id, Name, Mobile_number, Gender, Date_Created, Fee, Date_Of_Birth)
VALUES
('APG857','Adebayo Omololu',50075,'M',GETDATE(),700,'1969-06-17'),
('APG895', 'Feyi Oye',50076,'F',GETDATE(),500,'1978-01-29');

-- Delete
DELETE FROM Preps_ng WHERE Mobile_number = 50073;

-- Alter table
ALTER TABLE Preps_ng ADD Extra_Column VARCHAR(100);

-- Truncate table
TRUNCATE TABLE Preps_ng;

-- Drop table
DROP TABLE Preps_ng;

--How the update table works

SELECT *
FROM [HumanResources].[Employee];

UPDATE [HumanResources].[Employee]
SET JOBTITLE = 'Senior Design Engineer'
where [JobTitle] in ('Design Engineer', 'Research and Development Manager', 'Tool Designer');

--Retrieve BusinessEntityID where JobTitle is Design Engineer

SELECT [BusinessEntityID], [JobTitle]
FROM [HumanResources].[Employee]
WHERE [JobTitle] = ('Design Engineer');


-- Retrieve BusinessEntityID, JobTitle and Marital status using CASE 
SELECT [BusinessEntityID],
		[JobTitle],
		CASE 
			WHEN [MaritalStatus] = 'M' THEN 'Married'
			ELSE 'Single'
		END AS Status
from [HumanResources].[Employee];

--Retrieve Employee Details Including Marital Status, Organization Level Segment, Vacation Classification, and ID Length

SELECT [BusinessEntityID],
		[JobTitle],
		CASE 
			WHEN [MaritalStatus] = 'M' THEN 'Married'
			ELSE 'Single'
		END AS Status,
		CASE 
			WHEN [OrganizationLevel] = 1 THEN 'Snr Magmnt'
			WHEN [OrganizationLevel] = 2 THEN 'Mid Level Magmnt'
			WHEN [OrganizationLevel] = 3 THEN 'Manager'
			WHEN [OrganizationLevel] = 4 THEN 'Team Member'
			ELSE 'CEO'
		END AS Employee_Segment,
		CASE 
			WHEN [VacationHours] <= 30 THEN 'Good'
			WHEN [VacationHours] BETWEEN 31 AND 50 THEN 'Warning'
			WHEN [VacationHours] >= 51  THEN 'Bad'
       END  ,
	    len([NationalIDNumber]) character_length
FROM [HumanResources].[Employee];


			


