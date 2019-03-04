--Creating the Stored ProcedureCREATE PROCEDURE uspSalesFiltering	@Cust_FName VARCHAR(30), 	@Cust_LName VARCHAR(30), 	@DOB DATE, 	@Ord_Date DATEAS DECLARE @CUST_ID INTSET @CUST_ID = (SELECT CustomerID FROM SampleDB_Naga.dbo.tblCUSTOMER				WHERE FirstName = @Cust_FName				AND LastName = @Cust_LName				AND BirthDate = @DOB)SELECT C.FirstName, C.LastName, P.ProductName, O.OrderDate FROM SampleDB_Naga.dbo.tblORDER OJOIN  SampleDB_Naga.dbo.tblCUSTOMER C ON C.CustomerID = O.CustomerIDJOIN SampleDB_Naga.dbo.tblPRODUCT P ON P.ProductID = O.ProductIDWHERE C.CustomerID = @Cust_ID	  AND O.OrderDate > @Ord_Date



--Executing the stored procedure
EXECUTE uspSalesFiltering
@Cust_FName = 'Polo',
@Cust_LName = 'Sailor',
@DOB = 'October 3, 2012',
@Ord_Date = 'February 1, 2017'


