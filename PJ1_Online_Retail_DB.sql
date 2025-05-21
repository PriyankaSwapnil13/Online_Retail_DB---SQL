 --Create the Database
create database PJ1_Online_Retai_lDB;
Go

--Use the Database
use PJ1_Online_Retai_lDB;
GO

--Create the customer table

create table Customers_Table
(Customer_ID int primary key Identity(1,1),
FirstName nvarchar(50),
LastName nvarchar(50), 
Email nvarchar(100),
Phone nvarchar(50),
Address nvarchar(255),
City nvarchar(50),
State nvarchar(50),
ZipCode nvarchar(50),
Country nvarchar(50),
CreatedAt DateTime Default GetDate()
);

--Create the Product Table

Create Table Product(
ProductId int Primary key Identity (1,1),
ProductName nvarchar(100),
CategoryId Int,
Price Decimal(10,2),
Stock Int,
CreateAt DateTime Default GetDate()
);

--Create the Categories Table

Create Table Categories(
CategoryID  int primary key identity (1,1),
CategoryName nvarchar(100),
Description nvarchar(255)
);

--Create Orders Table

Create Table Orders(
OrderId int primary key identity (1,1),
Customer_ID int,
OrderDate DateTime Default GetDate(),
TotalAmount Decimal(10,2)
Foreign Key (Customer_ID) References Customers_Table(Customer_ID)
);

--Create the OrderItems table

Create Table OrderItems (
OrderItemID int primary key identity (1,1),
OrderId int,
ProductId int,
Quantity int,
Price decimal (10,2),
Foreign key (ProductId)  references Product (ProductId),
Foreign key (OrderId) references Orders (OrderId)
);

--Insert sample data into [dbo].[Categories] table

Insert into dbo.Categories(CategoryName,Description) values('Electronics','Devices and Gadgets');	
Insert into dbo.Categories(CategoryName,Description) values('Clothing','Apparel and Accessories');
Insert into dbo.Categories(CategoryName,Description) values('Books','Electronics and printed books');

--Insert sample data into [dbo].[Product] table

Insert into dbo.Product(ProductName,CategoryId,Price,Stock) Values
('SmartPhone', 1, 699.99, 50),
('Laptop', 1, 999.99, 30),
('T-shirt',2, 19.99,100),
('Jeans', 2,49.99, 60),
('Fiction Novel', 3, 14.99, 200),
('Science Journal', 3, 29.99, 150);

--Insert sample data into [dbo].[Customers_Table]

Insert into dbo.Customers_Table (FirstName,LastName,Email,Phone,Address,City,State,ZipCode,Country) values
('Sameer','Khanna', 'sameer.khana@example.com', '123-456-7809','123 Elm st.', 'Springfield', 'IL', '62701', 'USA'),
('Jane','Smith', 'Jane.smith@example.com', '443-456-7229','456 Oak st.', 'Madison', 'WI', '59701', 'USA'),
('Harshad','Patel', 'harshad.patel@example.com', '473-456-3309','789 Dalal st.', 'Mumbai', 'Maharshtra', '41720', 'India');

Insert into dbo.Customers_Table (FirstName,LastName,Email,Phone,Address,City,State,ZipCode,Country) values
('Ishwar','Panchariya', 'Ishwar.Panchariya@example.com', '723-638-7809','123 Elm st.', 'Springfield', 'IL', '62701', 'USA');

select * from [dbo].[Customers_Table]

--Insert sample data into[dbo].[Orders]

Insert into Orders([Customer_ID],[OrderDate],[TotalAmount])
(1, GETDATE(), 719.98),
(2, GETDATE(), 49.99),
(3, GETDATE(), 44.95);

--Insert sample data into[dbo].[OrderItems]

Insert into [dbo].[OrderItems](OrderId,ProductId,Quantity,Price) values
(1,1,1,699.99),
(1,3,1,19.99),
(2,4,1,49.99),
(3,5,1,14.99),
(3,6,1,29.99);

Insert into Orders([Customer_ID],[OrderDate],[TotalAmount])
values (3, GETDATE(), 3499.95);

Insert into [dbo].[OrderItems](OrderId,ProductId,Quantity,Price) values
(1,1,5,699.99);	

select * from OrderItems;
select * from Orders;

select 5*699.99;

--Query 1: Retrieve all orders for a specific customer

Select o.[OrderId],o.[OrderDate],o.[TotalAmount],oi.[ProductId],p.[ProductName],oi.[Quantity],oi.[Price]
From Orders o
Join OrderItems oi on o.OrderId = oi.OrderId
Join Product p on oi.ProductId = p.ProductId
where o.[Customer_ID] = 1;

--Query 2: Find the total sales for each product

select p.[ProductId],p.[ProductName],sum(oi.[Quantity]*oi.[Price]) As TotalSales
from OrderItems oi
Join Product p on oi.ProductId = p.ProductId
Group by p.ProductId, p.ProductName
order by TotalSales Desc;

--Query 3: Calculate the average order value

select AVG([TotalAmount]) as AvgOrderValues from [dbo].[Orders];

--Query 4: List the top 5 customers by total spending

select [Customer_ID], [FirstName],[LastName],TotalSpent, rn
from(
Select c.[Customer_ID],c.[FirstName],c.[LastName], SUM(o.TotalAmount) as TotalSpent,
Row_number() over (order by sum(o.TotalAmount)desc) as rn	
from [dbo].[Customers_Table] c
join [dbo].[Orders] o
on c. [Customer_ID] = o. [Customer_ID]
group by c.[Customer_ID],c.[FirstName],c.[LastName])
sub where rn <=5;

--Query 5: Retrieve the most popular product category

Select [CategoryID],[CategoryName],TotalQuantitySold,rn
from (
select c.[CategoryID],c.[CategoryName],SUM(oi.[Quantity]) as TotalQuantitySold,
ROW_NUMBER() over (order by sum(oi.[Quantity] )desc) as rn
from [dbo].[OrderItems] oi
join [dbo].[Product] p
on oi.[ProductId] = p.[ProductId]
join [dbo].[Categories] c
on p.CategoryId = c.CategoryID
group by  c.[CategoryID],c.[CategoryName]) sub
where rn = 1 ;

--Query 6: List all products that are out of stock
--Insert the row with 0 stock

Insert into dbo.Product(ProductName,CategoryId,Price,Stock) Values
('Keyboard', 1, 39.99, 0);

Select * from [dbo].[Product] where [Stock] = 0; 
--or
Select [ProductId],[ProductName],[Stock] from [dbo].[Product]
where stock = 0;

--with categoary name

Select p.[ProductId],p.[ProductName],c.[CategoryID],p.[Stock] 
from [dbo].[Product] p join [dbo].[Categories] c
on p.[CategoryID] = c.[CategoryID]
where stock = 0;

--Query 7: Find customers who placed orders in the last 30 days

Select c.[Customer_ID],c.[FirstName],c.[LastName],c.[Email],c.[Phone]	
from [dbo].[Customers_Table] c join [dbo].[Orders] o
on c.Customer_ID = o.Customer_ID
where o.OrderDate >= DATEADD(DAY,-30, GETDATE());	

--Query 8: Calculate the total number of orders placed each month

Select YEAR([OrderDate]) as orderyear,
MONTH([OrderDate]) as Ordermonth,
COUNT([OrderId]) as Totalorders
from [dbo].[Orders]
Group by YEAR([OrderDate]), MONTH([OrderDate])
Order by orderyear, Ordermonth;

--Query 9: Retrieve the details of the most recent order

Select Top 1 o.[OrderId],o.[OrderDate],o.[TotalAmount],c.[FirstName],c.[LastName]
from [dbo].[Orders] o 
join [dbo].[Customers_Table] c	
on o.Customer_ID = c.Customer_ID
order by o.OrderDate desc;

--Query 10: Find the average price of products in each category

Select c.[CategoryID],c.[CategoryName],Avg(p.[Price]) as AvgPrice
from [dbo].[Categories] c join [dbo].[Product] p 
on c.[CategoryId] = p.[CategoryId]
Group by c.[CategoryId], c.[CategoryName];

--Query 11: List customers who have never placed an order

Select c.[Customer_ID],c.[FirstName],c.[LastName],c.[Email],c.[Phone],o.[OrderId], o.TotalAmount
from [dbo].[Customers_Table] c full join [dbo].[Orders] o
on c.[Customer_ID] = o.[Customer_ID]
--where o.[OrderId] is null ;

--Query 12: Retrieve the total quantity sold for each product

Select p.[ProductId],p.[ProductName],sum(oi.[Quantity]) as TotalSoldQuantity
from [dbo].[Product] p join [dbo].[OrderItems] oi
on p.[ProductId] = oi.[ProductId]
group by p.[ProductId],p.[ProductName]
order by p.[ProductName];

--Query 13: Calculate the total revenue generated from each category

Select c.[CategoryId], c.[CategoryName], sum(oi.[Quantity]*oi.[Price]) as TotalRevenue
from  [dbo].[OrderItems] oi join [dbo].[Product] p
on oi. [ProductId] = p.[ProductId]
join [dbo].[Categories] c
on c.[CategoryID] = p.[CategoryID]
Group by c.[CategoryId], c.[CategoryName]
Order by TotalRevenue desc;

--Query 14: Find the highest-priced product in each category

Select c.[CategoryID],c.[CategoryName],p1.[ProductId],p1.[ProductName],p1.[Price]
from [dbo].[Categories] c join [dbo].[Product] p1 
on c.[CategoryId] = p1.[CategoryId]
where p1.[Price] = (select max([Price])from [dbo].[Product] p2 where p2.[CategoryId] = p1.[CategoryId])
order by p1.[Price] desc ; 

--Query 15: Retrieve orders with a total amount greater than a specific value (e.g., $500)

Select o.[OrderId],c.[Customer_ID],c.[FirstName],c.[LastName], o.[TotalAmount]
from [dbo].[Orders] o join [dbo].[Customers_Table] c
on o.[Customer_ID] = c.[Customer_ID]
where o.[TotalAmount] >= 49.99
order by o.[TotalAmount] desc;

--Query 16: List products along with the number of orders they appear in

Select p.[ProductId], p.[ProductName], count(oi.[OrderItemID]) as OrderCount
from [dbo].[Product] p join [dbo].[OrderItems] oi
on p.[ProductId] = oi.[ProductId]
group by p.[ProductId], p.[ProductName]
order by OrderCount desc;

--Query 17: Find the top 3 most frequently ordered products

Select Top 3 p.[ProductId],p.[ProductName], COUNT(oi.[OrderId]) as Ordercount
from [dbo].[OrderItems] oi join [dbo].[Product] p 
on oi.[ProductId] = p.[ProductId]
Group by p.[ProductId],p.[ProductName]
order by Ordercount desc;

--Query 18: Calculate the total number of customers from each country

Select [Country], Count([Customer_ID]) as TotalCustomer
from [dbo].[Customers_Table] group by [Country] order by TotalCustomer desc;

--Query 19: Retrieve the list of customers along with their total spending

Select c.[Customer_ID], c.[FirstName], c.[LastName], sum(o.[TotalAmount]) as TotalSpending
from [dbo].[Customers_Table] c join [dbo].[Orders] o
on c.[Customer_ID] = o.[Customer_ID]
Group by c.[Customer_ID], c.[FirstName], c.[LastName];

--Query 20: List orders with more than a specified number of items (e.g., 2 items)

select	o.[OrderId], c.[Customer_ID],c.[FirstName], c.[LastName], COUNT(oi.[OrderItemID]) as Numberofitems
from [dbo].[Orders] o join [dbo].[OrderItems] oi
on o.OrderId = oi.OrderId
join [dbo].[Customers_Table] c
on o.Customer_ID = c.Customer_ID
group by o.[OrderId], c.[Customer_ID],c.[FirstName], c.[LastName]
having COUNT (oi.OrderItemID) >= 2
order by Numberofitems;

	
-- Create a Log Table

Create table ChangeLog
(LogID Int Primary Key Identity (1,1),
 TableName Nvarchar (50),
 Operation Nvarchar (10),
 RecordId Int,
 ChangeDate DateTime Default GetDate(),
 ChangeBy Nvarchar (100) );

 A. Triggers for Products Table
-- Trigger for INSERT on Products table
Create or alter Trigger trg_insert_product
on [dbo].[Product]
After Insert
as
Begin

Insert into ChangeLog(TableName,Operation,RecordId,ChangeBy)
Select 'Product', 'Insert', inserted.[ProductId],SYSTEM_USER
from inserted;

print 'Insert operation logged for products table'

End;
go
--Insert one record into the products table

Insert into [dbo].[Product] ([ProductName],[CategoryId],[Price],[Stock])
Values ('Wireless Mouse', 1,4.99,20); 

Insert into [dbo].[Product] ([ProductName],[CategoryId],[Price],[Stock])
Values ('Spiderman multiverse comic', 3,2.50,150); 

Select * from [dbo].[Product];
select * from [dbo].[ChangeLog];

-- Trigger for UPDATE on Products table

Create or Alter Trigger trg_update_product
on [dbo].[Product]
After update
as
begin 

Insert into ChangeLog(TableName,Operation,RecordId,ChangeBy)
Select 'Product', 'update', inserted.[ProductId],SYSTEM_USER
from inserted;

print 'Update operation logged for products table'

End;
go

update [dbo].[Product]set Price = 300 where [ProductId] = 2;

select * from [dbo].[Product];

-- Trigger for DELETE on Products table

Create or alter Trigger trg_delete_product
on [dbo].[Product]
After Delete
as
Begin

Insert into ChangeLog(TableName,Operation,RecordId,ChangeBy)
Select 'Product', 'Delete', deleted.[ProductId],SYSTEM_USER
from inserted;

print 'Delete operation logged for products table'

End;
Go

Set Nocount On;

Delete from Product where ProductId = 10;

Step 2: Create Triggers for Each Table

-----------------------

	B. Triggers for Customers Table
-- Trigger for INSERT on Customers table

Create or Alter Trigger trg_insert_Customers_Table
On [dbo].[Product]
after insert 
as begin 
	set nocount on;

-- Insert a record into ChangeLog Table

Insert into ChangeLog(TableName,Operation,RecordId,ChangeBy)
Select 'Customers_Table', 'insert', inserted.Customer_ID, SYSTEM_USER
from inserted;

--Display the message indicating that the triggerhas fired.

print 'insert  operation logged for Customers_Table.';
end;
go


	-- Trigger for UPDATE on Customers table

		Create or Alter Trigger trg_update_product
On [dbo].[Product]
after update 
as begin 
	set nocount on;

-- Insert a record into ChangeLog Table

Insert into ChangeLog(TableName,Operation,RecordId,ChangeBy)
Select 'Customer', 'Update', inserted.Customer_ID,SYSTEM_USER
from inserted;

--Display the message indicating that the triggerhas fired.

print 'Update  operation logged for Customer table.';
end;
go

-- Trigger for DELETE on Customers table


Create or Alter Trigger trg_delete_product
On [dbo].[Product]
after delete 
as begin 
	set nocount on;

-- Insert a record into ChangeLog Table

Insert into ChangeLog(TableName,Operation,RecordId,ChangeBy)
Select 'Customer', 'delete', inserted.Customer_ID,SYSTEM_USER
from deleted;

--Display the message indicating that the triggerhas fired.

print 'delete  operation logged for Customer table.';
end;
go

----------------------

--Indexes
Indexes are	crucial for optimizing the performance of your SQL Server database, 
especially for read-heavy operations like SELECT queries. 

--Let's create indexes for the OnlineRetailDB database to improve query performance.

A. Indexes on Categories Table
	1. Clustered Index on CategoryID: Usually created with the primary key.
*/

USE OnlineRetailDB;
GO
-- Clustered Index on Categories Table (CategoryID)
CREATE CLUSTERED INDEX IDX_Categories_CategoryID
ON Categories(CategoryID);
GO

/*
B. Indexes on Products Table
	1. Clustered Index on ProductID: This is usually created automatically when 
	   the primary key is defined.
	2. Non-Clustered Index on CategoryID: To speed up queries filtering by CategoryID.
	3. Non-Clustered Index on Price: To speed up queries filtering or sorting by Price.
*/

-- Drop Foreign Key Constraint from OrderItems Table - ProductID
ALTER TABLE OrderItems DROP CONSTRAINT FK__OrderItem__Produ__440B1D61;

-- Clustered Index on Products Table (ProductID)
CREATE CLUSTERED INDEX IDX_Products_ProductID 
ON Products(ProductID);
GO

-- Non-Clustered Index on CategoryID: To speed up queries filtering by CategoryID.
CREATE NONCLUSTERED INDEX IDX_Products_CategoryID
ON Products(CategoryID);
GO

-- Non-Clustered Index on Price: To speed up queries filtering or sorting by Price.
CREATE NONCLUSTERED INDEX IDX_Products_Price
ON Products(Price);
GO

-- Recreate Foreign Key Constraint on OrderItems (ProductID Column)
ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_Products
FOREIGN KEY (ProductID) REFERENCES Products(ProductID);
GO

/*
C. Indexes on Orders Table
	1. Clustered Index on OrderID: Usually created with the primary key.
	2. Non-Clustered Index on CustomerID: To speed up queries filtering by CustomerID.
	3. Non-Clustered Index on OrderDate: To speed up queries filtering or sorting by OrderDate.
*/

-- Drop Foreign Key Constraint from OrderItems Table - OrderID
ALTER TABLE OrderItems DROP CONSTRAINT FK__OrderItem__Order__44FF419A;

-- Clustered Index on OrderID
CREATE CLUSTERED INDEX IDX_Orders_OrderID
ON Orders(OrderID);
GO

-- Non-Clustered Index on CustomerID: To speed up queries filtering by CustomerID.
CREATE NONCLUSTERED INDEX IDX_Orders_CustomerID
ON Orders(CustomerID);
GO

--  Non-Clustered Index on OrderDate: To speed up queries filtering or sorting by OrderDate.
CREATE NONCLUSTERED INDEX IDX_Orders_OrderDate
ON Orders(OrderDate);
GO

-- Recreate Foreign Key Constraint on OrderItems (OrderID Column)
ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_OrderID
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID);
GO

/*
D. Indexes on OrderItems Table
	1. Clustered Index on OrderItemID: Usually created with the primary key.
	2. Non-Clustered Index on OrderID: To speed up queries filtering by OrderID.
	3. Non-Clustered Index on ProductID: To speed up queries filtering by ProductID.
*/

-- Clustered Index on OrderItemID
CREATE CLUSTERED INDEX IDX_OrderItems_OrderItemID
ON OrderItems(OrderItemID);
GO

-- Non-Clustered Index on OrderID: To speed up queries filtering by OrderID.
CREATE NONCLUSTERED INDEX IDX_OrderItems_OrderID
ON OrderItems(OrderID);
GO

--  Non-Clustered Index on ProductID: To speed up queries filtering by ProductID.
CREATE NONCLUSTERED INDEX IDX_OrderItems_ProductID
ON OrderItems(ProductID);
GO


/*

E. Indexes on Customers Table
	1. Clustered Index on CustomerID: Usually created with the primary key.
	2. Non-Clustered Index on Email: To speed up queries filtering by Email.
	3. Non-Clustered Index on Country: To speed up queries filtering by Country.
*/

-- Drop Foreign Key Constraint from Orders Table - CustomerID
ALTER TABLE Orders DROP CONSTRAINT FK__Orders__Customer__403A8C7D;

-- Clustered Index on CustomerID
CREATE CLUSTERED INDEX IDX_Customers_CustomerID
ON Customers(CustomerID);
GO

-- Non-Clustered Index on Email: To speed up queries filtering by Email.
CREATE NONCLUSTERED INDEX IDX_Customers_Email
ON Customers(Email);
GO

--  Non-Clustered Index on Country: To speed up queries filtering by Country.
CREATE NONCLUSTERED INDEX IDX_Customers_Country
ON Customers(Country);
GO

-- Recreate Foreign Key Constraint on Orders (CustomerID Column)
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_CustomerID
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);
GO

use PJ1_Online_Retai_lDB;
GO
select * from [dbo].[Categories];
select * from [dbo].[ChangeLog];
select * from [dbo].[Customers_Table];
select * from [dbo].[OrderItems];
select * from [dbo].[Orders];
select * from [dbo].[Product];

----------------------
--View

-- View for Product Details: A view combining product details with category names.
create view vw_productDetails AS
select [ProductId],[ProductName],[Price],[Stock],[CategoryName]
from [dbo].[Product] p inner join [dbo].[Categories] c
on p.CategoryId = c.CategoryID;
GO

-- Display product details with category names using view
select * from vw_productDetails;


-- View for Customer Orders : A view to get a summary of orders placed by each customer.

create view vw_customer_orders
AS
select c.[Customer_ID],c.[FirstName],c.[LastName],count(o.[OrderId]) as TotalOrders,
sum(oi.[Quantity]*p.[Price]) as TotalAmount
from [dbo].[Customers_Table] c 
inner join [dbo].[Orders] o on c.Customer_ID = o.Customer_ID
inner join [dbo].[OrderItems] oi on o.OrderId = oi.OrderId
inner join [dbo].[Product] p on oi.ProductId = p.ProductId
group by c.[Customer_ID],c.[FirstName],c.[LastName]
Go

select * from vw_customer_orders;

-- View for Recent Orders: A view to display orders placed in the last 30 days.
create view vw_RecentOrders
As
select o.[OrderId], o.[OrderDate], c.[Customer_ID],c.[FirstName],c.[LastName],
sum(oi.[Quantity] * oi.[Price]) as OrderAmount
from [dbo].[Customers_Table] c
inner join [dbo].[Orders] o on c.Customer_ID = o.Customer_ID
inner join [dbo].[OrderItems] oi on o.OrderId = oi.OrderId
group by o.OrderId, o.OrderDate, c.Customer_ID, c.FirstName,c.LastName;
go

select * from vw_RecentOrders;

-- Retrieve All Products with Category Names
--Using the vw_ProductDetails view to get a list of all products along with their category names.

select * from [dbo].[vw_productDetails];

-- Retrieve Products within a Specific Price Range
--Using the vw_ProductDetails view to find products priced between $100 and $500.

select * from [dbo].[vw_productDetails] where price between 100 and 500;

--Count the Number of Products in Each Category
--Using the vw_ProductDetails view to count the number of products in each category.

select [CategoryName], COUNT([ProductId]) as product_count
from [dbo].[vw_productDetails]
group by [CategoryName];

--Retrieve Customers with More Than 1 Orders
--Using the vw_CustomerOrders view to find customers who have placed more than 1 orders.

select * from [dbo].[vw_customer_orders] where TotalOrders > 1;

--Retrieve the Total Amount Spent by Each Customer
--Using the vw_CustomerOrders view to get the total amount spent by each customer.

select [Customer_ID],[FirstName],[LastName],[TotalAmount] from [dbo].[vw_customer_orders]
order by TotalAmount desc;

--Retrieve Recent Orders Above a Certain Amount
--Using the vw_RecentOrders view to find recent orders where the total amount is greater than $1000.

select * from[dbo].[vw_RecentOrders] where OrderAmount > 1000;

-- Retrieve the Latest Order for Each Customer
--Using the vw_RecentOrders view to find the latest order placed by each customer.
select ro.OrderId,ro.Customer_ID,ro.OrderDate,ro.FirstName,ro.LastName,ro.OrderAmount
from [dbo].[vw_RecentOrders] ro
inner join
(select Customer_ID, max(OrderDate) as latestOrderDate from [dbo].[vw_RecentOrders] 
group by Customer_ID)
latest 
on ro.Customer_ID = latest.Customer_ID and ro.OrderDate = latest.latestOrderDate
Order by ro.OrderDate desc;
go

--Query 38: Retrieve Products in a Specific Category
--Using the vw_ProductDetails view to get all products in a specific category, such as 'Electronics'.
select * from [dbo].[vw_productDetails] where [CategoryName] = 'Books';

--Query 39: Retrieve Total Sales for Each Category
--Using the vw_ProductDetails and vw_CustomerOrders views to calculate the total sales for each category.

select pd.CategoryName, sum(oi.Quantity*p.Price) as TotalSales
from [dbo].[OrderItems] oi
inner join [dbo].[Product] p 
on oi.ProductId = p.ProductId
inner join [dbo].[vw_productDetails] pd 
on p.ProductId = pd.ProductId
group by pd.CategoryName
order by TotalSales desc;

--Query 40: Retrieve Customer Orders with Product Details
--Using the vw_CustomerOrders and vw_ProductDetails views to get customer orders along with the details 
-- of the products ordered.
select co.Customer_ID,co.FirstName,co.LastName,o.OrderId,o.OrderDate,
pd.ProductName, oi.Quantity,pd.Price
from [dbo].[Orders] o 
inner join [dbo].[OrderItems] oi on o.OrderId = oi.OrderId
inner join [dbo].[vw_productDetails] pd on oi.ProductId = pd.ProductId
inner join [dbo].[vw_customer_orders] co on	o.Customer_ID = co.Customer_ID
order by o.OrderDate desc;

--Query 41: Retrieve Top 5 Customers by Total Spending
--Using the vw_CustomerOrders view to find the top 5 customers based on their total spending.

select Top 5 Customer_ID, [FirstName],[LastName],[TotalAmount]
from vw_customer_orders order by [TotalAmount] desc;

--Query 42: Retrieve Products with Low Stock
--Using the vw_ProductDetails view to find products with stock below a certain threshold, such as 10 units.
select * from [dbo].[vw_productDetails] where [Stock]<50;

--Query 43: Retrieve Orders Placed in the Last 7 Days
--Using the vw_RecentOrders view to find orders placed in the last 7 days.
select * from [dbo].[vw_RecentOrders] where OrderDate >= DATEADD(day, -7, getdate());

--Query 44: Retrieve Products Sold in the Last Month
--Using the vw_RecentOrders view to find products sold in the last month.
select p.ProductId, p.ProductName, sum(oi.[Quantity]) as TotalSold
from [dbo].[Orders] o
inner join [dbo].[OrderItems] oi on o.OrderId = oi.OrderId
inner join [dbo].[Product] p on oi.ProductId = p.ProductId
where o.OrderDate >= dateadd(MONTH, -1, GETDATE())
group by p.ProductId,p.ProductName
order by TotalSold desc;








