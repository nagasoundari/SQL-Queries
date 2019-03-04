USE G2

--Function Definition
 CREATE FUNCTION fn_calcTotalSpentTribb (@CustID INT)
 RETURNS numeric(4,2) --some data type
 AS
 BEGIN
	DECLARE @Ret numeric(4,2) =
		(SELECT SUM(P.Price * O.Quantity)
		FROM G2.dbo.tblCUSTOMER C
		JOIN G2.dbo.tblORDER O ON O.CustID = C.CustID
		JOIN G2.dbo.tblPRODUCT P ON P.ProdID = O.ProdID  
		WHERE C.CustID = @CustID AND DateDiff(Day, O.OrderDate, GETDATE()) < 365
		GROUP BY C.CustID)
	RETURN @Ret

 END


 ---Function Call
 ALTER TABLE tblCUSTOMER
 ADD TotalAmtSpentNaga AS (dbo.fn_calcTotalSpentTribb(CustID))



 ---What is the math?
	--To calculate the total amount spent, we have to sum up the (Price * Quantity).

---Where does this column live?
	--This column lives in the tblCUSTOMER.

---What is our parameter?
	--CustID is our parameter.