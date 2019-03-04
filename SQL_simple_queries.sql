--1) Write the SQL code to determine which customers are from the zip code 80471.
SELECT * from [CUSTOMER_BUILD].dbo.tblCUSTOMER
WHERE CustomerZIP = '80471';


--2) Write the SQL code to determine which customers have ‘Blvd’ in their address.
SELECT * FROM [CUSTOMER_BUILD].dbo.tblCUSTOMER
WHERE CustomerAddress LIKE '%Blvd%'


--3) Write the SQL code to determine which customers have last names that match the pattern ‘F**R’ (read ‘F in position one and R in position four’) and reside in either Florida or Texas.
SELECT * FROM [CUSTOMER_BUILD].dbo.tblCUSTOMER
WHERE CustomerState IN ('Florida, FL', 'Texas, TX') AND CustomerLname LIKE 'F__r%'

--4) Write the SQL code to determine which customers have a first name beginning with ‘Ra’ and live in California.
SELECT * FROM [CUSTOMER_BUILD].dbo.tblCUSTOMER
WHERE CustomerState = 'California, CA' AND CustomerFname LIKE 'Ra%'


--5) Write the SQL code to determine which customers have ‘Leaf’ in their address and have the two letters ‘ba’ together in any part of the county they live in.
SELECT * FROM [CUSTOMER_BUILD].dbo.tblCUSTOMER
Where CustomerAddress LIKE '%leaf%' and CustomerCounty LIKE '%ba%'


--6) Write the SQL code to determine which states have at least 100,000 customers.
SELECT COUNT(*), CustomerState 
 FROM [CUSTOMER_BUILD].dbo.tblCUSTOMER 
GROUP BY CustomerState
HAVING COUNT(*) >= 100000 


--7) Write the SQL code to determine which customers are at least 65 years - old and do NOT live in Wyoming, Iowa, Colorado or Nebraska.
SELECT * FROM [CUSTOMER_BUILD].dbo.tblCUSTOMER
WHERE DATEDIFF(Year, DateOfBirth, GetDate()) >= 65 
		AND CustomerState NOT IN('Wyoming, WY', 'Iowa, IA', 'Colorado, CO','Nebraska, NE')


--8) Write the SQL code to determine which customers are younger than 50, have a phone number in area code '206', '360' or '425' and also have a last name beginning with 'J'.
SELECT * FROM [CUSTOMER_BUILD].dbo.tblCUSTOMER
WHERE DATEDIFF(Year, DateOfBirth, GetDate()) < 50 
	AND AreaCode in ('206', '360', '425')
	AND CustomerLname LIKE 'J%'


--9) Write the SQL code to determine who the oldest customer is from Florida.
SELECT TOP(1) * FROM [CUSTOMER_BUILD].dbo.tblCUSTOMER 
WHERE CustomerState = 'Florida, FL'
ORDER BY DateOfBirth 

--10) Write the SQL code to determine the average age of all customers from Oregon. (this one is a bit tricky!)
SELECT AVG(DATEDIFF(Year, DateOfBirth, GetDate())) FROM [CUSTOMER_BUILD].dbo.tblCUSTOMER as AverageAge
WHERE CustomerState = 'Oregon, OR'


