USE FlexPhoneDatabase
GO

-- simulate sales transaction

-- seorang customer ingin membeli produk di Flex Phone
-- staff membuatkan member untuk customer
INSERT INTO MsCustomer VALUES
('CU011','Michael tanto','Tanto@sunib.edu','1998-07-22','Male','+6281211332287');

-- customer mulai melakukan transaksi
INSERT INTO SalesTransactionHeader VALUES
('SH017','ST006','CU011',GETDATE());

-- staff mulai memasukan detail transaksi
INSERT INTO SalesTransactionDetail VALUES 
('SH017','PO001',1),
('SH017','PO022',3);



-- simulate purchase transaction

-- ada vendor yang ingin menjual produk
-- vendor mengisi data diri
INSERT INTO MsVendor VALUES
('VE011','Chris Sinad','Chris13@bluejack.com','+6281200453456','Jl K.H Sumur 13');

-- vendor melakukan transaksi
INSERT INTO PurchaseTransactionHeader VALUES
('PH016','ST001','VE011',GETDATE());

-- staff memasukan detail transaksi
INSERT INTO PurchaseTransactionDetail VALUES
('PH016','PO015',2),
('PH016','PO017',4),
('PH016','PO020',1);