CREATE DATABASE FlexPhoneDatabase
GO
USE FlexPhoneDatabase
GO

CREATE TABLE MsCustomer(
	CustomerId CHAR(5) PRIMARY KEY,
	CustomerName VARCHAR(100)
		CHECK(LEN(CustomerName) > 3) NOT NULL,
	CustomerEmail VARCHAR(50)
		CHECK(CustomerEmail LIKE '%@bluejack.com' OR CustomerEmail LIKE '%@sunib.edu') NOT NULL,
	CustomerDOB DATE NOT NULL,
	CustomerGender VARCHAR(7)
		CHECK(CustomerGender IN('Male','Female')) NOT NULL,
	CustomerPhoneNumber VARCHAR(15) NOT NULL
);

CREATE TABLE MsStaff(
	StaffId CHAR(5) PRIMARY KEY,
	StaffName VARCHAR(100) NOT NULL,
	StaffEmail VARCHAR(50)
		CHECK(StaffEmail LIKE '%@bluejack.com' OR StaffEmail LIKE '%@sunib.edu') NOT NULL,
	StaffDOB DATE
		CHECK(YEAR(StaffDOB) > 1959) NOT NULL,
	StaffGender VARCHAR(7)
		CHECK(StaffGender IN('Male','Female')) NOT NULL,
	StaffPhoneNumber VARCHAR(15) NOT NULL,
	StaffAddress VARCHAR(100) NOT NULL,
	StaffSalary INT NOT NULL
);

CREATE TABLE MsVendor(
	VendorId CHAR(5) PRIMARY KEY,
	VendorName VARCHAR(100) NOT NULL,
	VendorEmail VARCHAR(50)
		CHECK(VendorEmail LIKE '%@bluejack.com' OR VendorEmail LIKE '%@sunib.edu') NOT NULL,
	VendorPhoneNumber VARCHAR(15) NOT NULL,
	VendorAddress VARCHAR(100) NOT NULL
);

CREATE TABLE MsPhoneBrand(
	BrandId CHAR(5) PRIMARY KEY,
	BrandName VARCHAR(100) NOT NULL
);

CREATE TABLE MsPhone(
	PhoneId CHAR(5) PRIMARY KEY,
	BrandId CHAR(5)
		FOREIGN KEY REFERENCES MsPhoneBrand(BrandId)
		ON UPDATE CASCADE 
		ON DELETE CASCADE NOT NULL,
	PhoneName VARCHAR(100) NOT NULL,
	PhonePrice INT
		CHECK(PhonePrice BETWEEN 100000 AND 40000000) NOT NULL
);

CREATE TABLE PurchaseTransactionHeader(
	PurchaseId CHAR(5) PRIMARY KEY,
	StaffId CHAR(5)
		FOREIGN KEY REFERENCES MsStaff(StaffId)
		ON UPDATE CASCADE
		ON DELETE CASCADE NOT NULL,
	VendorId CHAR(5)
		FOREIGN KEY REFERENCES MsVendor(VendorId)
		ON UPDATE CASCADE
		ON DELETE CASCADE NOT NULL,
	TransactionDate DATE NOT NULL
);

CREATE TABLE PurchaseTransactionDetail(
	PurchaseId CHAR(5)
		FOREIGN KEY REFERENCES PurchaseTransactionHeader(PurchaseId)
		ON UPDATE CASCADE
		ON DELETE CASCADE NOT NULL,
	PhoneId CHAR(5)
		FOREIGN KEY REFERENCES MsPhone(PhoneId)
		ON UPDATE CASCADE
		ON DELETE CASCADE NOT NULL,
	Quantity INT NOT NULL,
	PRIMARY KEY(PurchaseId,PhoneId)
);

CREATE TABLE SalesTransactionHeader(
	SalesId CHAR(5) PRIMARY KEY,
	StaffId CHAR(5)
		FOREIGN KEY REFERENCES MsStaff(StaffId)
		ON UPDATE CASCADE
		ON DELETE CASCADE NOT NULL,
	CustomerId CHAR(5)
		FOREIGN KEY REFERENCES MsCustomer(CustomerId)
		ON UPDATE CASCADE
		ON DELETE CASCADE NOT NULL,
	TransactionDate DATE NOT NULL
);

CREATE TABLE SalesTransactionDetail(
	SalesId CHAR(5)
		FOREIGN KEY REFERENCES SalesTransactionHeader(SalesId)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	PhoneId CHAR(5)
		FOREIGN KEY REFERENCES MsPhone(PhoneId)
		ON UPDATE CASCADE
		ON DELETE CASCADE NOT NULL,
	Quantity INT NOT NULL,
	PRIMARY KEY(SalesId,PhoneId)
);