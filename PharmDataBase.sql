Create Database PharmacyDatabase;

use PharmacyDatabase;

alter database PharmacyDatabase set multi_user;

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
select * from Product;

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

EXEC sp_rename 'sale.producctId', 'productId', 'COLUMN';


create table category (
catId int primary key identity,
catName nvarchar(30)); 

create table LoginTable (
userId int primary key,
userName nvarchar(30),
userPassword nvarchar(30));

create table purchaseBill(
billId int primary key identity,
billNo int,
purchaseId int);

create table purchase(
purId int primary key identity(1,3),
productId int,
supplierId int,
purchaseDate date,
productQuantity int,
total int);

create table [user](id int primary key identity,Username nvarchar(50),password nvarchar(50));

insert into [user](Username,password) values('Anas','Anas');

--create table Bill( BllId int primary key identity,BillNo int,SaleId int);

ALTER TABLE Bill
ADD CONSTRAINT FK_Bill_Sale FOREIGN KEY (SaleId) REFERENCES sale(sid);
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


ALTER TABLE sale
DROP CONSTRAINT FK_Sale_Product;

ALTER TABLE sale
ADD CONSTRAINT FK_Sale_Product
FOREIGN KEY (productId)
REFERENCES Product(pid)
ON DELETE CASCADE;

-- Drop the existing foreign key constraint
ALTER TABLE sale
DROP CONSTRAINT FK_Sale_Customer;

-- Recreate the foreign key with ON DELETE CASCADE
ALTER TABLE sale
ADD CONSTRAINT FK_Sale_Customer
FOREIGN KEY (customerId)
REFERENCES Customer(cid)
ON DELETE CASCADE;


-- Drop the existing foreign key constraint
ALTER TABLE Bill
DROP CONSTRAINT FK_Bill_Sale;

-- Recreate the foreign key with ON DELETE CASCADE
ALTER TABLE Bill
ADD CONSTRAINT FK_Bill_Sale
FOREIGN KEY (SaleId)
REFERENCES sale(sid)
ON DELETE CASCADE;


CREATE PROCEDURE InsertProduct
  @pname NVARCHAR(50),
  @packSize NVARCHAR(20),
  @location NVARCHAR(50),
  @generic NVARCHAR(50),
  @expiryDate DATE,
  @sale_rate INT,
  @purchase_rate INT,
  @batchNo NVARCHAR(20),
  @quantity INT,
  @company NVARCHAR(50),
  @ptype NVARCHAR(20)
AS
BEGIN
  INSERT INTO Product (pname, packSize, location, generic, expiryDate, sale_rate, purchase_rate, batchNo, quantity, company, ptype)
  VALUES (@pname, @packSize, @location, @generic, @expiryDate, @sale_rate, @purchase_rate, @batchNo, @quantity, @company, @ptype)
END

DROP PROCEDURE IF EXISTS InsertProduct;

CREATE PROCEDURE UpdateProduct
  @pid INT,
  @pname NVARCHAR(50),
  @packSize NVARCHAR(20),
  @location NVARCHAR(50),
  @generic NVARCHAR(50),
  @expiryDate DATE,
  @sale_rate INT,
  @purchase_rate INT,
  @batchNo NVARCHAR(20),
  @quantity INT,
  @company NVARCHAR(50),
  @ptype NVARCHAR(20)
AS
BEGIN
  UPDATE Product
  SET 
    pname = @pname,
    packSize = @packSize,
    location = @location,
    generic = @generic,
    expiryDate = @expiryDate,
    sale_rate = @sale_rate,
    purchase_rate = @purchase_rate,
    batchNo = @batchNo,
    quantity = @quantity,
    company = @company,
    ptype = @ptype
  WHERE pid = @pid;
END

CREATE PROCEDURE DeleteProduct
  @pid INT
AS
BEGIN
  DELETE FROM Product
  WHERE pid = @pid;
END


CREATE TRIGGER trgAfterProductUpdate
ON Product
FOR UPDATE
AS
BEGIN
    DECLARE @pid INT,
            @oldQuantity INT, @newQuantity INT,
            @oldSaleRate INT, @newSaleRate INT,
            @oldPurchaseRate INT, @newPurchaseRate INT;

    -- Get the Product ID and the old and new values
    SELECT @pid = i.pid, 
           @oldQuantity = d.quantity, @newQuantity = i.quantity,
           @oldSaleRate = d.sale_rate, @newSaleRate = i.sale_rate,
           @oldPurchaseRate = d.purchase_rate, @newPurchaseRate = i.purchase_rate
    FROM inserted i
    JOIN deleted d ON i.pid = d.pid;

    -- Insert into the ProductHistory table for tracking changes
    INSERT INTO ProductHistory (ProductId, OldQuantity, NewQuantity, OldSaleRate, NewSaleRate, OldPurchaseRate, NewPurchaseRate, ChangeDate, Action)
    VALUES (@pid, @oldQuantity, @newQuantity, @oldSaleRate, @newSaleRate, @oldPurchaseRate, @newPurchaseRate, GETDATE(), 'UPDATE');
END
	
CREATE TABLE ProductHistory (
    HistoryId INT IDENTITY PRIMARY KEY,
    ProductId INT,
    OldQuantity INT,
    NewQuantity INT,
    OldSaleRate INT,
    NewSaleRate INT,
    OldPurchaseRate INT,
    NewPurchaseRate INT,
    ChangeDate DATETIME,
    Action NVARCHAR(50)  -- Either 'UPDATE' or 'DELETE'
);
CREATE TRIGGER trgAfterProductUpdate
ON Product
FOR UPDATE
AS
BEGIN
    DECLARE @pid INT,
            @oldQuantity INT, @newQuantity INT,
            @oldSaleRate INT, @newSaleRate INT,
            @oldPurchaseRate INT, @newPurchaseRate INT;

    -- Get the Product ID and the old and new values
    SELECT @pid = i.pid, 
           @oldQuantity = d.quantity, @newQuantity = i.quantity,
           @oldSaleRate = d.sale_rate, @newSaleRate = i.sale_rate,
           @oldPurchaseRate = d.purchase_rate, @newPurchaseRate = i.purchase_rate
    FROM inserted i
    JOIN deleted d ON i.pid = d.pid;

    -- Insert into the ProductHistory table for tracking changes
    INSERT INTO ProductHistory (ProductId, OldQuantity, NewQuantity, OldSaleRate, NewSaleRate, OldPurchaseRate, NewPurchaseRate, ChangeDate, Action)
    VALUES (@pid, @oldQuantity, @newQuantity, @oldSaleRate, @newSaleRate, @oldPurchaseRate, @newPurchaseRate, GETDATE(), 'UPDATE');
END

CREATE TRIGGER trgAfterProductDelete
ON Product
FOR DELETE
AS
BEGIN
    DECLARE @pid INT,
            @oldQuantity INT, 
            @oldSaleRate INT, 
            @oldPurchaseRate INT;

    -- Get the Product ID and the old values of the product
    SELECT @pid = d.pid, 
           @oldQuantity = d.quantity,
           @oldSaleRate = d.sale_rate,
           @oldPurchaseRate = d.purchase_rate
    FROM deleted d;

    -- Insert into the ProductHistory table for tracking deletions
    INSERT INTO ProductHistory (ProductId, OldQuantity, NewQuantity, OldSaleRate, NewSaleRate, OldPurchaseRate, NewPurchaseRate, ChangeDate, Action)
    VALUES (@pid, @oldQuantity, NULL, @oldSaleRate, NULL, @oldPurchaseRate, NULL, GETDATE(), 'DELETE');
END

-- Create InsertPurchase stored procedure
CREATE PROCEDURE InsertPurchase
    @productId INT,
    @supplierId INT,
    @purchaseDate DATE,
    @productQuantity INT,
    @total INT
AS
BEGIN
    -- Insert a new purchase record into the Purchase table
    DECLARE @purId INT;

    INSERT INTO Purchase (productId, supplierId, purchaseDate, productQuantity, total)
    VALUES (@productId, @supplierId, @purchaseDate, @productQuantity, @total);

    -- Get the generated purId for the newly inserted purchase record
    SET @purId = SCOPE_IDENTITY();

    -- Insert the purchase bill into the purchaseBill table
    INSERT INTO purchaseBill (billNo, purchaseId)
    VALUES ((SELECT MAX(billNo) + 1 FROM purchaseBill), @purId);  -- Automatically increments the billNo

    -- Return the purId of the inserted purchase
    SELECT @purId AS PurchaseId;
END

-- Create UpdatePurchase stored procedure
CREATE PROCEDURE UpdatePurchase
    @purId INT,
    @productId INT,
    @supplierId INT,
    @purchaseDate DATE,
    @productQuantity INT,
    @total INT
AS
BEGIN
    -- Update the existing purchase record in the Purchase table
    UPDATE Purchase
    SET productId = @productId,
        supplierId = @supplierId,
        purchaseDate = @purchaseDate,
        productQuantity = @productQuantity,
        total = @total
    WHERE purId = @purId;

    -- Update the corresponding purchase bill if necessary (optional)
    UPDATE purchaseBill
    SET billNo = (SELECT MAX(billNo) + 1 FROM purchaseBill)
    WHERE purchaseId = @purId;

    -- Return the updated Purchase ID
    SELECT @purId AS PurchaseId;
END

-- Create InsertBill stored procedure
CREATE PROCEDURE InsertBill
    @billNo INT,
    @saleId INT
AS
BEGIN
    -- Insert a new bill record into the Bill table
    INSERT INTO Bill (BillNo, SaleId)
    VALUES (@billNo, @saleId);

    -- Return the generated Bill ID
    SELECT SCOPE_IDENTITY() AS BillId;
END


