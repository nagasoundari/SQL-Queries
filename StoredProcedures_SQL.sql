--Creating the Stored Procedure



--Executing the stored procedure
EXECUTE uspSalesFiltering
@Cust_FName = 'Polo',
@Cust_LName = 'Sailor',
@DOB = 'October 3, 2012',
@Ord_Date = 'February 1, 2017'


