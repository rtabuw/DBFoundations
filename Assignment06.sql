--*************************************************************************--
-- Title: Assignment06
-- Author: RaulTabile
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2022-05-28,RaulTabile,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_RaulTabile')
	 Begin 
	  Alter Database [Assignment06DB_RaulTabile] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_RaulTabile;
	 End
	Create Database Assignment06DB_RaulTabile;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_RaulTabile;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- Used SELECT statements to view the Categories, Products, Employees, and Inventories columns. 

-- SELECT * FROM Categories
-- SELECT * FROM Products
-- SELECT * FROM Employees
-- SELECT * FROM Inventories

-- Create the vCategories view with the columns in Categories table.

CREATE VIEW vCategories
  WITH SCHEMABINDING AS
    SELECT CategoryID, CategoryName
    FROM dbo.Categories;
Go

-- Use SELECT statment to verify columns

-- Select * FROM vCategories

-- Create the vCategories view with the columns in Products table.

CREATE VIEW vProducts
  WITH SCHEMABINDING AS
    SELECT ProductID, ProductName, CategoryID, UnitPrice
    FROM dbo.Products;
Go

-- Use SELECT statment to verify columns

-- Select * FROM vProducts

-- Create the vCategories view with the columns in Employees table.

CREATE VIEW vEmployees
  WITH SCHEMABINDING AS
    SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
    FROM dbo.Employees;
Go

-- Use SELECT statment to verify columns

-- Select * FROM vEmployees

-- Create the vCategories view with the columns in Inventories table.

CREATE VIEW vInventories
  WITH SCHEMABINDING AS
    SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
    FROM dbo.Inventories;
Go

-- Use SELECT statment to verify columns

-- Select * FROM vInventories


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Create the statements to deny access.

DENY SELECT ON Categories TO Public;
DENY SELECT ON Products TO Public;
DENY SELECT ON Employees TO Public;
DENY SELECT ON Inventories TO Public;
Go

-- Create the statements to allow access.

GRANT SELECT ON Categories TO Public;
GRANT SELECT ON Products TO Public;
GRANT SELECT ON Employees TO Public;
GRANT SELECT ON Inventories TO Public;
Go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

-- Modified the code from Assignment05, Question 1 to create the query below.  Used a SELECT statement
--  (commented out) to view the result of the query.

CREATE VIEW vCategoriesandProducts AS
  SELECT TOP 1000 
    vCategories.CategoryName, vProducts.ProductName, vProducts.UnitPrice
    FROM vCategories INNER JOIN vProducts
      ON vCategories.CategoryID = vProducts.CategoryID
  ORDER BY CategoryName, ProductName;
Go

-- SELECT * FROM vCategoriesandProducts



-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33

-- Modified the code from Assignment05, Question 2 to create the query below.  Used a SELECT statement
--  (commented out) to view the result of the query.

CREATE VIEW vProductsandInventories AS
  SELECT TOP 1000 
    vProducts.ProductName, vInventories.InventoryDate, vInventories.[Count]
    FROM vProducts INNER JOIN vInventories
      ON vProducts.ProductID = vInventories.ProductID
  ORDER BY ProductName, InventoryDate, [Count];
Go

-- SELECT * FROM vProductsandInventories


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Modified the code from Assignment05, Question 3 to create the query below.  Used a SELECT statement
--  (commented out) to view the result of the query.

CREATE VIEW vInventoriesandEmployees AS
  SELECT DISTINCT TOP 1000 
      vInventories.InventoryDate,
      EmployeeFirstName +' '+ EmployeeLastName AS EmployeeName
    FROM vInventories INNER JOIN vEmployees
      ON vInventories.EmployeeID = vEmployees.EmployeeID
  ORDER BY InventoryDate, EmployeeName;
Go

-- SELECT * FROM vInventoriesandEmployees


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37

-- Modified the code from Assignment05, Question 4 to create the query below.  Used a SELECT statement
--  (commented out) to view the result of the query.

CREATE VIEW vCatProdInv AS
  SELECT TOP 1000 
    vCategories.CategoryName, vProducts.ProductName, 
    vInventories.InventoryDate, vInventories.[Count]
  FROM vInventories INNER JOIN vProducts 
    ON vInventories.ProductID = vProducts.ProductID
    INNER JOIN vCategories
    ON vProducts.CategoryID = vCategories.CategoryID
  ORDER BY CategoryName, ProductName, InventoryDate, [Count];
Go

-- SELECT * FROM vCatProdInv


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  C?te de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaran? Fant?stica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalik??ri	      2017-01-01	  57	  Steven Buchanan

-- Modified the code from Assignment05, Question 5 to create the query below.  Used a SELECT statement
--  (commented out) to view the result of the query.

CREATE VIEW vCatProdInvByEmp AS
  SELECT TOP 1000 
    vCategories.CategoryName, vProducts.ProductName, 
    vInventories.InventoryDate, vInventories.[Count],
    EmployeeFirstName +' '+ EmployeeLastName AS EmployeeName
  FROM vEmployees INNER JOIN vInventories
    ON vEmployees.EmployeeID = vInventories.EmployeeID
    INNER JOIN vProducts 
    ON vInventories.ProductID = vProducts.ProductID
    INNER JOIN vCategories
    ON vProducts.CategoryID = vCategories.CategoryID
  ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
Go

-- SELECT * FROM vCatProdInvByEmp


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth

-- Modified the code from Assignment05, Question 6 to create the query below.  Used a SELECT statement
--  (commented out) to view the result of the query.

CREATE VIEW vCatProdInvChaiandChangByEmp AS
  SELECT TOP 1000 
    vCategories.CategoryName, vProducts.ProductName, 
    vInventories.InventoryDate, vInventories.[Count],
    EmployeeFirstName +' '+ EmployeeLastName AS EmployeeName
  FROM vEmployees INNER JOIN vInventories
    ON vEmployees.EmployeeID = vInventories.EmployeeID
    INNER JOIN vProducts 
    ON vInventories.ProductID = vProducts.ProductID
    INNER JOIN vCategories
    ON vProducts.CategoryID = vCategories.CategoryID
  WHERE ProductName IN ('Chai','Chang')
  ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
Go

-- SELECT * FROM vCatProdInvChaiandChangByEmp


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King

-- Modified the code from Assignment05, Question 7 to create the query below.  Used a SELECT statement
--  (commented out) to view the result of the query.

CREATE VIEW vEmployeesandManagers AS
  SELECT TOP 1000 
    M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
  FROM vEmployees AS E
    INNER JOIN vEmployees AS M
    ON M.EmployeeID = E.ManagerID
  ORDER BY Manager, Employee;
Go

-- SELECT * FROM vEmployeesandManagers



-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaran? Fant?stica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaran? Fant?stica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaran? Fant?stica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth

-- Used the code from Assignment05, Question 5 for reference to create the query below.  Used a SELECT statement
--  (commented out) to view the result of the query.

CREATE VIEW vAllBasicViews AS
  SELECT TOP 10000 
    vCategories.CategoryID, vCategories.CategoryName,
    vProducts.ProductID, vProducts.ProductName, vProducts.UnitPrice,
    vInventories.InventoryID, vInventories.InventoryDate, vInventories.Count,
    vEmployees.EmployeeID,
    vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName AS Employee	
  FROM vEmployees INNER JOIN vInventories
    ON vEmployees.EmployeeID = vInventories.EmployeeID
    INNER JOIN vProducts 
    ON vInventories.ProductID = vProducts.ProductID
    INNER JOIN vCategories
    ON vProducts.CategoryID = vCategories.CategoryID
  ORDER BY CategoryID, ProductID, InventoryID, Employee;
Go

-- SELECT * FROM vAllBasicViews


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vCategoriesandProducts]
Select * From [dbo].[vProductsandInventories]
Select * From [dbo].[vInventoriesandEmployees]
Select * From [dbo].[vCatProdInv]
Select * From [dbo].[vCatProdInvByEmp]
Select * From [dbo].[vCatProdInvChaiandChangByEmp]
Select * From [dbo].[vEmployeesandManagers]
Select * From [dbo].[vAllBasicViews]

/***************************************************************************************/