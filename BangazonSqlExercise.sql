--List each employee first name, last name and supervisor status along with their 
--department name. Order by department name, then by employee last name, and finally by employee first name. 
SELECT e.FirstName, e.LastName, 
CASE 
	WHEN e.IsSupervisor = 1 THEN 'Yes'
	ELSE 'No'
END AS SupervisorStatus,
	 d.[Name] AS DepartmentName 
FROM Employee e INNER JOIN  Department d ON e.DepartmentId = d.Id
ORDER BY d.[Name], e.LastName, e.FirstName;

--List each department ordered by budget amount with the highest first.
SELECT [Name] AS DepartmentName, Budget FROM Department
ORDER BY Budget DESC;

--List each department name along with any employees (full name) in that department who are supervisors.
SELECT d.[Name] AS DepartmentName, e.FirstName + ' ' + e.LastName AS FullName 
FROM Department d LEFT JOIN Employee e ON d.Id = e.DepartmentId
WHERE IsSupervisor = 1;

--List each department name along with a count of employees in each department.
SELECT d.[Name] AS DepartmentName, COUNT(e.Id) AS EmployeeCount 
FROM Department d LEFT JOIN Employee e ON d.Id = e.DepartmentId
GROUP BY d.[Name];

--Write a single update statement to increase each department's budget by 20%

UPDATE Department
SET Budget = Budget + (Budget * 20.0 / 100.0);

--List the employee full names for employees who are not signed up for any training programs.
SELECT e.FirstName + ' ' + e.LastName AS EmployeeName
FROM Employee e LEFT JOIN EmployeeTraining et ON e.Id = et.EmployeeId
WHERE et.Id is Null;

--List the employee full names for employees who are signed up for at least one training program and include the number of 
--training programs they are signed up for.
SELECT e.FirstName + ' ' + e.LastName AS EmployeeName, COUNT(et.Id) AS NumberOfTrainingProgram
FROM Employee e LEFT JOIN EmployeeTraining et ON e.Id = et.EmployeeId
WHERE et.Id is NOT Null
GROUP BY  e.FirstName, e.LastName;

--List all training programs along with the count employees who have signed up for each.
SELECT tp.[Name] AS TrainingProgram, COUNT(et.Id) AS EmployeeCount 
FROM TrainingProgram tp LEFT JOIN EmployeeTraining et ON tp.Id = et.TrainingProgramId
GROUP BY tp.[Name];

--List all training programs who have no more seats available.
SELECT tp.[Name] AS TrainingProgram, tp.MaxAttendees, COUNT(et.Id) AS EmployeeCount 
FROM TrainingProgram tp LEFT JOIN EmployeeTraining et ON tp.Id = et.TrainingProgramId
GROUP BY tp.[Name], tp.MaxAttendees
HAVING MaxAttendees = COUNT(et.Id)

--List all future training programs ordered by start date with the earliest date first
SELECT tp.[Name] AS TrainingProgram, tp.StartDate, tp.EndDate FROM TrainingProgram tp
WHERE tp.StartDate > GetDate()
ORDER BY tp.StartDate

--Assign a few employees to training programs of your choice.
INSERT INTO EmployeeTraining (EmployeeId, TrainingProgramId) VALUES (20, 1);
INSERT INTO EmployeeTraining (EmployeeId, TrainingProgramId) VALUES (26, 14);
INSERT INTO EmployeeTraining (EmployeeId, TrainingProgramId) VALUES (17, 15);
INSERT INTO EmployeeTraining (EmployeeId, TrainingProgramId) VALUES (18, 15);

--List the top 3 most popular training programs. (For this question, consider each record in the training program
--table to be a UNIQUE training program).

SELECT TOP 3 tp.Id, tp.[Name] AS TrainingProgram, COUNT(et.Id) AS EmployeeCount FROM TrainingProgram tp
INNER JOIN EmployeeTraining et ON tp.Id = et.TrainingProgramId
GROUP BY tp.Id, tp.[Name]
ORDER BY COUNT(et.Id) DESC

--List the top 3 most popular training programs. 
--(For this question consider training programs with the same name to be the SAME training program)
SELECT TOP 3 tp.[Name] AS TrainingProgram, COUNT(et.Id) AS EmployeeCount FROM TrainingProgram tp
INNER JOIN EmployeeTraining et ON tp.Id = et.TrainingProgramId
GROUP BY tp.[Name]
ORDER BY COUNT(et.Id) DESC

--List all employees who do not have computers.
SELECT e.FirstName + ' ' + e.LastName AS EmployeeName, ce.Id
FROM Employee e LEFT JOIN ComputerEmployee ce ON e.Id = ce.EmployeeId
WHERE ce.Id is Null;

--List all employees along with their current computer information make and manufacturer combined into a field entitled ComputerInfo. 
--If they do not have a computer, this field should say "N/A".

SELECT e.FirstName + ' ' + e.LastName AS EmployeeFullName, IsNull(c.Make + ' ' + c.Manufacturer, 'N/A') AS ComputerInfo
FROM Employee e LEFT JOIN ComputerEmployee ce ON e.Id = ce.EmployeeId
LEFT JOIN Computer c ON ce.ComputerId = c.Id

--List all computers that were purchased before July 2019 that are have not been decommissioned

SELECT c.Make + ' ' + c.Manufacturer AS ComputerInfo, c.PurchaseDate, c.DecomissionDate FROM Computer c
WHERE c.PurchaseDate <= '2019-07-31' AND c.DecomissionDate is  Null

--List all employees along with the total number of computers they have ever had.
SELECT e.FirstName + ' ' + e.LastName AS EmployeeFullName, COUNT(ce.Id) AS NumberOfComputer
FROM Employee e INNER JOIN ComputerEmployee ce ON e.Id = ce.EmployeeId
GROUP BY e.FirstName, e.LastName

--List the number of customers using each payment type
SELECT c.FirstName + ' ' + c.LastName AS CustomerFullName, pt.[Name] AS PaymentType, pt.AcctNumber AS AccountNumber
FROM Customer c INNER JOIN PaymentType pt ON c.Id = pt.CustomerId
ORDER BY c.FirstName

--List the 10 most expensive products and the names of the seller

SELECT TOP 10 p.Title, p.[Description], p.Quantity, Max(p.Price) AS Price, c.FirstName + ' ' + c.LastName AS SellerName FROM Product p
INNER JOIN Customer c ON p.CustomerId = c.Id
GROUP BY p.Title, p.[Description], p.Quantity, c.FirstName, c.LastName
ORDER BY Max(p.Price) DESC

--List the 10 most purchased products and the names of the seller
SELECT TOP 10 p.Title, p.[Description], p.Quantity, p.Price, COUNT(op.Id) AS PurchaseProduct, c.FirstName + ' ' + c.LastName AS SellerName FROM Product p
INNER JOIN OrderProduct op ON p.Id = op.ProductId
INNER JOIN Customer c ON p.CustomerId = c.Id
GROUP BY p.Title, p.[Description], p.Quantity, p.Price, c.FirstName, c.LastName
ORDER BY COUNT(op.Id) DESC

--Find the name of the customer who has made the most purchases
SELECT c.FirstName + ' ' + c.LastName AS CustomerName, COUNT(o.Id) AS NumberOfOrders FROM Customer c
INNER JOIN [Order] o ON c.Id = o.CustomerId
GROUP BY c.FirstName, c.LastName
ORDER BY COUNT(o.Id) DESC

--List the amount of total sales by product type

								
SELECT pt.Id AS ProductTypeId, pt.[Name] AS ProductType, ISNULL(SUM(sales.Price),0) AS TotalSales FROM ProductType pt
LEFT JOIN (SELECT p.Price, p.ProductTypeId FROM Product p INNER JOIN OrderProduct op ON op.ProductId = p.Id)
 Sales ON Sales.ProductTypeId = pt.Id
 GROUP BY pt.Id, pt.[Name]
 ORDER BY SUM(sales.Price) DESC

--List the total amount made from all sellers
SELECT c.FirstName + ' ' + c.LastName AS SellerName, IsNull(SUM(sales.Price),0) as TotalAmount FROM Customer c
LEFT JOIN (SELECT p.Price, p.CustomerId FROM Product p INNER JOIN OrderProduct op ON op.ProductId = p.Id)
Sales ON Sales.CustomerId = c.Id
Group By c.FirstName,c.LastName
Order By c.FirstName



