USE FlexPhoneDatabase
GO

--1
SELECT [Display ID] = 'Customer'+ CONVERT(VARCHAR(3),CONVERT(INT,RIGHT(mc.CustomerId,3))),
	mc.CustomerName,
	mc.CustomerGender,
	[total amount of spending] = SUM(std.Quantity*mp.PhonePrice)
FROM MsCustomer mc
JOIN SalesTransactionHeader sth ON mc.CustomerId = sth.CustomerId
JOIN SalesTransactionDetail std ON sth.SalesId=std.SalesId
JOIN MsPhone mp ON std.PhoneId = mp.PhoneId
GROUP BY mc.CustomerName,mc.CustomerGender,mc.CustomerId

--2
SELECT ms.StaffId,
	[Name] = LEFT(StaffName,CHARINDEX(' ',StaffName)-1),
	[Customer Count] = COUNT(DISTINCT(sth.CustomerId))
FROM MsStaff ms
JOIN SalesTransactionHeader sth ON ms.StaffId  = sth.StaffId
WHERE CHARINDEX(' ',StaffName) != 0
GROUP BY ms.StaffId,ms.StaffName

--3
SELECT [Display ID] = 'Customer'+ CONVERT(VARCHAR(3),CONVERT(INT,RIGHT(mc.CustomerId,3))),
	mc.CustomerName,
	[Phone Brand] = mpb.BrandName,
	[total spending] = SUM(std.Quantity*mp.PhonePrice)
FROM MsCustomer mc
JOIN SalesTransactionHeader sth ON mc.CustomerId = sth.CustomerId
JOIN SalesTransactionDetail std ON sth.SalesId = sth.SalesId
JOIN MsPhone mp ON mp.PhoneId = std.PhoneId AND std.SalesId=sth.SalesId
JOIN MsPhoneBrand mpb ON mpb.BrandId = mp.BrandId
WHERE CHARINDEX(' ',mc.CustomerName) != 0
GROUP BY mc.CustomerId,mc.CustomerName,mpb.BrandName
HAVING COUNT(DISTINCT(std.PhoneId))>3

--4
SELECT ms.StaffId,
	[Email] = SUBSTRING(ms.StaffEmail,0,CHARINDEX('@',ms.StaffEmail)-1)+'@Ymail.com',
	[phone brand] = mpb.BrandName,
	[total selling] = SUM(std.Quantity*mp.PhonePrice)
FROM MsStaff ms
JOIN SalesTransactionHeader sth ON ms.StaffId = sth.StaffId
JOIN SalesTransactionDetail std ON sth.SalesId = std.SalesId
JOIN MsPhone mp ON mp.PhoneId = std.PhoneId AND std.SalesId = sth.SalesId
JOIN MsPhoneBrand mpb ON mp.BrandId = mpb.BrandId
GROUP BY ms.StaffId,ms.StaffEmail,mpb.BrandName
HAVING COUNT(DISTINCT(std.PhoneId)) > 2
ORDER BY ms.StaffId

--5
SELECT [Staff Email] = StaffEmail,
	[Staff Gender] = StaffGender,
	[Date of Birth] = CONVERT(VARCHAR(15),StaffDOB,106),
	[Salary] = CONCAT('Rp.',CONVERT(VARCHAR(10),StaffSalary),',00.')
FROM MsStaff
WHERE DATEDIFF(YEAR,StaffDOB,GETDATE()) >= 30 AND
	StaffSalary > (
		SELECT AVG(CONVERT(BIGINT,StaffSalary))
		FROM MsStaff
	)

--6
SELECT ms.StaffId,
	ms.StaffName,
	[StaffPhone] = CONCAT('08',SUBSTRING(StaffPhoneNumber,4,LEN(StaffPhoneNumber)-3)),
	[Total Selling] = A.SumOfAll
FROM MsStaff ms,(
	SELECT SumOfAll = SUM(std.Quantity*mp.PhonePrice),
		sth.StaffId
	FROM SalesTransactionHeader sth
	JOIN SalesTransactionDetail std ON sth.SalesId = std.SalesId
	JOIN MsPhone mp ON mp.PhoneId = std.PhoneId AND std.SalesId = sth.SalesId
	JOIN MsPhoneBrand mpb ON mp.BrandId = mpb.BrandId
	GROUP BY sth.StaffId
) A
WHERE ms.StaffId = A.StaffId AND
	A.SumOfAll BETWEEN 10000000 AND 100000000 AND
	ms.StaffGender = 'Male'

--7
SELECT [Staff No] = 'Staff No' + CONVERT(VARCHAR(3),CONVERT(INT,RIGHT(ms.StaffId,3))),
	ms.StaffName,
	[Email] = SUBSTRING(ms.StaffEmail,1,CHARINDEX('@',ms.StaffEmail)-1) + '@gmail.com',
	[Date of Birth] = CONVERT(VARCHAR(20),ms.StaffDOB,103),
	[Customer Count] = B.MaxCount
FROM MsStaff ms,(
	SELECT sth.staffId,
		CustomerCount = COUNT(DISTINCT(sth.CustomerId))
	FROM SalesTransactionHeader sth
	GROUP BY sth.StaffId
) A,(
	SELECT MaxCount = MAX(A.CustomerCount)
	FROM(
		SELECT sth.staffId,
			CustomerCount = COUNT(DISTINCT(sth.CustomerId))
		FROM SalesTransactionHeader sth
		GROUP BY sth.StaffId
	) A
) B
WHERE B.MaxCount = A.CustomerCount AND A.StaffId = ms.StaffId

--8
SELECT [PhoneBrandId] = A.BrandId,
	[PhoneBrand] = A.BrandName,
	[CustomerID] = mc.CustomerId,
	mc.CustomerName,
	[Customer Email] = SUBSTRING(mc.CustomerEmail,1,CHARINDEX('@',mc.CustomerEmail)-1) + '@gmail.com',
	[Qty] = A.qty
FROM MsCustomer mc,(
	SELECT sth.CustomerId,
		mpb.BrandId,
		mpb.BrandName,
		qty = SUM(std.Quantity)
	FROM SalesTransactionHeader sth
	JOIN SalesTransactionDetail std ON sth.SalesId = std.SalesId
	JOIN MsPhone mp ON mp.PhoneId = std.PhoneId AND std.SalesId = sth.SalesId
	JOIN MsPhoneBrand mpb ON mp.BrandId = mpb.BrandId
	GROUP BY sth.CustomerId,mpb.BrandId,mpb.BrandName
) A,(
	SELECT A.BrandId,
		maxbrand = MAX(A.qty)
	FROM (
		SELECT sth.CustomerId,
			mpb.BrandId,
			qty = SUM(std.Quantity)	
		FROM SalesTransactionHeader sth
		JOIN SalesTransactionDetail std ON sth.SalesId = std.SalesId
		JOIN MsPhone mp ON mp.PhoneId = std.PhoneId AND std.SalesId = sth.SalesId
		JOIN MsPhoneBrand mpb ON mp.BrandId = mpb.BrandId
		GROUP BY sth.CustomerId,mpb.BrandId
	) A
	GROUP BY A.BrandId
) B
WHERE B.maxbrand = A.qty AND B.BrandId = A.BrandId AND A.CustomerId = mc.CustomerId AND
	mc.CustomerEmail LIKE '%@bluejack.com' AND 
	CONVERT(INT,RIGHT(mc.CustomerId,3)) % 2 = 0
ORDER BY A.BrandId

--9
GO
CREATE VIEW Vendor_Brand_Transaction_View AS(
	SELECT [VendorID] = 'Vendor'+CONVERT(VARCHAR(3),CONVERT(INT,RIGHT(mv.VendorId,3))),
		mv.VendorName,
		[PhoneNumber] = CONCAT('08',SUBSTRING(mv.VendorPhoneNumber,3,LEN(mv.vendorPhoneNumber)-3)),
		[PhoneBrand] = mpb.BrandName,
		[Transaction Count] = COUNT(DISTINCT(pth.PurchaseId)),
		[Total Transaction] = SUM(ptd.Quantity*mp.PhonePrice)
	FROM MsVendor mv
	JOIN PurchaseTransactionHeader pth ON mv.VendorId = pth.VendorId
	JOIN PurchaseTransactionDetail ptd ON pth.PurchaseId = ptd.PurchaseId
	JOIN MsPhone mp ON ptd.PhoneId = mp.PhoneId AND ptd.PurchaseId = pth.PurchaseId
	JOIN MsPhoneBrand mpb ON mp.BrandId = mpb.BrandId
	GROUP BY mv.VendorId,mv.VendorName,mv.VendorPhoneNumber,mpb.BrandName,mpb.BrandId
);
GO
SELECT *
FROM Vendor_Brand_Transaction_View

--10
GO
CREATE VIEW Staff_Selling_View AS(
	SELECT [StaffID] = ms.StaffId,
		ms.StaffName,
		[Sold Phone Count] = CONVERT(VARCHAR(10),SUM(std.Quantity)) + 'pc(s)',
		[Total Transaction] = CONCAT('Rp.',SUM(std.Quantity*mp.PhonePrice),',00.'),
		[Count Brand] = COUNT(DISTINCT(mp.BrandId))
	FROM MsStaff ms
	JOIN SalesTransactionHeader sth ON sth.StaffId = ms.StaffId
	JOIN SalesTransactionDetail std ON sth.SalesId = std.SalesId
	JOIN MsPhone mp ON mp.PhoneId = std.PhoneId AND std.SalesId = sth.SalesId
	WHERE ms.StaffEmail LIKE '%@bluejack.com'
	GROUP BY ms.StaffId,ms.StaffName,std.Quantity
);
GO
SELECT *
FROM Staff_Selling_View