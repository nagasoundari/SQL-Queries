/*--1) Write the SQL code to create a stored procedure to enter one row into tblORDER. Pass-in the following set of parameters:

a) @fname, @lname, @BirthDate ---> look-up needed CustomerID
b) @Product --> look-up productID
c) @Quantity --> pass through to INSERT statement
d) @OrderDate --> pass through to INSERT statement*/

CREATE PROCEDURE InsertNewOrder
	@Fname [varchar](30),
	@Lname [varchar](30),
	@BirthDate [date],
	@ProdName [varchar](50),
	@Quantity int,
	@OrderDate [date]

AS
DECLARE @ProdID INT 
DECLARE @CustID INT

SET @ProdID = (SELECT ProdID 
FROM tblPRODUCT 
WHERE ProdName = @ProdName)

SET @CustID = (SELECT CustID FROM tblCUSTOMER 
WHERE Fname = @Fname
AND Lname = @Lname 
AND BirthDate = @BirthDate)


BEGIN
INSERT INTO tblORDER(ProdID, CustID, Quantity, OrderDate)
VALUES (@ProdID, @CustID, @Quantity, @OrderDate)
END


--Execute the stored procedure to insert column
EXEC InsertNewOrder
@Fname = 'Sanda', @Lname = 'Bowell', @BirthDate = '1956-07-18', @ProdName = 'Veggie Pizza', @Quantity = 2, @OrderDate = '2018-12-18'

EXEC InsertNewOrder
@Fname = 'Sanda', @Lname = 'Bowell', @BirthDate = '1956-07-18', @ProdName = 'Leather Sofa', @Quantity = 2, @OrderDate = '2018-12-18'


/*===================================================================================================================================================================*/


/* 2) Write the SQL to implement a computed column that tracks total dollars spent by each customer.

	a) Code up a user-defined function --> pass the PK as a parameter!
	b) Don't forget to ALTER the appropriate table to hold this new column that calls the function just-created */



CREATE FUNCTION fn_calcDollarSpent (@CustID INT)
RETURNS numeric (8,2)
AS
BEGIN
DECLARE @Ret Numeric(8,2) = (SELECT SUM(P.Price * Quantity)FROM 
							tblPRODUCT P 
							JOIN tblORDER O ON P.ProdID = O.ProdID
							JOIN tblCUSTOMER C ON O.CustID = C.CustID
							WHERE @CustID = C.CustID)
RETURN @Ret 
END 


ALTER TABLE tblCUSTOMER 
ADD DollarSpent AS (dbo.fn_calcDollarSpent (CustID))


/*===================================================================================================================================================================*/

/* 3) Write the SQL to implement the following business rule:

"Customers under age 21 cannot place an order that includes more than $250 of clothing"

a) Make sure to use a user-defined function --> no parameter this time
b) Don't forget to ALTER the table that we are trying to restrict new data */


CREATE FUNCTION implementAgeRule()  
RETURNS INT  
AS
BEGIN

   DECLARE @Ret INT = 0  
   
   IF EXISTS (SELECT * 
	      FROM	tblPRODUCT P 
		  JOIN tblPRODUCT_TYPE PT ON  P.ProductTypeID = PT.ProductTypeID
		  JOIN tblORDER O ON O.ProdID = P.ProdID
		  JOIN tblCUSTOMER C ON C.CustID = O.CustID
		  WHERE (DateDiff(Day, C.BirthDate, GetDate()) / 365.25) < 21 
		  AND PT.ProductTypeName = 'Clothing'
		  AND (O.Quantity * P.Price) > 250)
	BEGIN
	SET @Ret = 1
	END
RETURN @Ret
END 
GO


ALTER TABLE tblORDER WITH NOCHECK
ADD CONSTRAINT Age_Price_ProdType_Check
CHECK (dbo.implementAgeRule() = 0)


/*===================================================================================================================================================================*/

/* 4) Write the SQL query to UPDATE the price of all products of type 'Tool' by 3% until the maximum price of any one specific tool is $650 
	  or the average price of all tools is greater than $425.

a) Consider using a WHILE loop
b) If you make a mistake and want to re-fresh your data you can create a 'new' database under a different name by re-running the RESTORE script at the top of this page.

*/


DECLARE @AVG_Price numeric (9,2)
DECLARE @MAX_Price numeric (9,2)


SET @AVG_Price = (SELECT AVG(P.Price) FROM 
					tblPRODUCT P 
					JOIN tblPRODUCT_TYPE PT ON P.ProductTypeID = PT.ProductTypeID
					WHERE PT.ProductTypeName = 'Tool')

SET @MAX_Price = (SELECT AVG(P.Price) FROM 
					tblPRODUCT P 
					JOIN tblPRODUCT_TYPE PT ON P.ProductTypeID = PT.ProductTypeID
					WHERE PT.ProductTypeName = 'Tool')

WHILE (@MAX_Price <= 650 OR @AVG_Price > 425)
BEGIN
	UPDATE P
	SET P.Price = P.Price * 1.03 FROM tblPRODUCT P JOIN tblPRODUCT_TYPE PT ON P.ProductTypeID = PT.ProductTypeID WHERE PT.ProductTypeName = 'Tool'
	SET @MAX_Price = (SELECT AVG(P.Price) FROM 
					tblPRODUCT P 
					JOIN tblPRODUCT_TYPE PT ON P.ProductTypeID = PT.ProductTypeID
					WHERE PT.ProductTypeName = 'Tool')

	SET @AVG_Price = (SELECT AVG(P.Price) FROM 
					tblPRODUCT P 
					JOIN tblPRODUCT_TYPE PT ON P.ProductTypeID = PT.ProductTypeID
					WHERE PT.ProductTypeName = 'Tool')
BREAK
END



/*===================================================================================================================================================================*/


/* 5) Write the SQL to determine the number of best selling product types under the following labels and condition:

* more than $100,000 in sales --> 'Gold'
* between $50,000 and $100,000 in sales --> 'Blue'
* between $25,000 and $49,999 in sales --> 'Green'
* Less than $25,000 ---> 'Red'
* otherwise 'unknown'

a) this is a CASE statement!
b) be sure to GROUP BY the CASE statement */


SELECT (CASE
       WHEN TotalSales > 100000
       THEN 'Gold'
       WHEN TotalSales BETWEEN 50000 AND 100000
       THEN 'Blue'
       WHEN TotalSales BETWEEN 25000 AND 49999
       THEN 'Green'
       WHEN TotalSales < 25000
       THEN 'Red'
       ELSE 'Unknown'
       END) AS SalesRange, COUNT(*) AS NumOfProdTypes
       FROM (SELECT PT.ProductTypeName, SUM(O.Quantity * P.Price) AS TotalSales
              FROM tblORDER O
                     JOIN tblPRODUCT P ON O.ProdID = P.ProdID
                     JOIN tblPRODUCT_TYPE PT ON P.ProductTypeID = PT.ProductTypeID
       GROUP BY PT.ProductTypeName) AS sub
GROUP BY (CASE
       WHEN TotalSales > 100000
       THEN 'Gold'
       WHEN TotalSales BETWEEN 50000 AND 100000
       THEN 'Blue'
       WHEN TotalSales BETWEEN 25000 AND 49999
       THEN 'Green' 
       WHEN TotalSales < 25000
       THEN 'Red' 
       ELSE 'Unknown'
       END)
