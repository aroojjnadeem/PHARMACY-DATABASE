--Create Database PharmacyDatabase;

use PharmacyDatabase;

create table Product (
pid int primary key identity(1,1),
pname nvarchar(50),
ptype nvarchar(20),
sale_rate int,
purchase_rate int,
quantity int,
expiryDate date,
company nvarchar(30),
generic nvarchar(30),
batchNo nvarchar(20),
packSize nvarchar(20),
location nvarchar(20));

create table customer(
cid int primary key identity (100,1),
cname nvarchar(40),
address nvarchar(40),
phoneNo nvarchar(20));

create table supplier (
spId int primary key identity (1,1),
spName nvarchar(30),
spAddress nvarchar(40),
spPhone nvarchar(15));

create table sale (
sid int primary key identity (2,2),
producctId int,
customerId int,
saleDate date,
productQuantity int,
total int);

create table purchase(
purId int primary key identity(1,3),
productId int,
supplierId int,
purchaseDate date,
productQuantity int,
total int);

create table category (
catId int primary key identity,
catName nvarchar(30)); 

create table LoginTable (
userId int primary key,
userName nvarchar(30),
userPassword nvarchar(30));

-- Use the PharmacyDatabase
USE PharmacyDatabase;

-- Add catId to the Product table to link it with the Category table
ALTER TABLE Product
ADD catId INT;

-- Add foreign key linking catId in Product to catId in Category
ALTER TABLE Product
ADD CONSTRAINT FK_Product_Category FOREIGN KEY (catId) REFERENCES category(catId);

-- In the sale table, link productId to the Product table and customerId to the Customer table
ALTER TABLE sale
ADD CONSTRAINT FK_Sale_Product FOREIGN KEY (productId) REFERENCES Product(pid),
    CONSTRAINT FK_Sale_Customer FOREIGN KEY (customerId) REFERENCES customer(cid);

-- In the purchase table, link productId to the Product table and supplierId to the Supplier table
ALTER TABLE purchase
ADD CONSTRAINT FK_Purchase_Product FOREIGN KEY (productId) REFERENCES Product(pid),
    CONSTRAINT FK_Purchase_Supplier FOREIGN KEY (supplierId) REFERENCES supplier(spId);
