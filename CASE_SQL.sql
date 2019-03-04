
/*1)  Write the SQL query to return the number of buildings owned by UW under the following labels:

a) If the building was opened before 1900, place it under ‘Classic’
b) If the building was opened between 1900 and 1950, place it under ‘Kind of old’
c) If the building was opened between 1951 and 2000, place it under ‘Modern’
d) Everything else place under 'Unknown' */


SELECT (CASE
	WHEN YearOpened < 1900
	THEN 'CLASSIC'
	WHEN YearOpened > 1900 AND  YearOpened < 1950
	THEN 'Kind of old'
	WHEN YearOpened > 1951 AND  YearOpened < 2000
	THEN 'Modern'
	ELSE 'Unknown'
	END) AS 'Building Label', COUNT(*) AS NumberOfBuildings
	FROM [UNIVERSITY].[dbo].[tblBUILDING]	
	GROUP BY (CASE
		WHEN YearOpened < 1900
		THEN 'CLASSIC'
		WHEN YearOpened > 1900 AND  YearOpened < 1950
		THEN 'Kind of old'
		WHEN YearOpened > 1951 AND  YearOpened < 2000
		THEN 'Modern'
		ELSE 'Unknown'
	END)




/*2) Write the SQL query to return the number of faculty that fall under the following categories:

a) Less that 1 year in position --> 'Fresh'
b) Between 1 and 3 years --> 'New-ish'
c) Between 3 and 12 years --> 'Comfortable'
d) Between 12 and 30 years --> 'Sorta tired'
e) Other --> 'probably dead' */



SELECT (CASE
	WHEN ExpinYears < 1
	THEN 'Fresh'
	WHEN ExpinYears >= 1 AND  ExpinYears < 3
	THEN 'New-ish'
	WHEN ExpinYears >= 3  AND  ExpinYears < 12
	THEN 'Comfortable'
	WHEN ExpinYears >= 12  AND  ExpinYears < 30
	THEN 'Sorta tired'
	ELSE 'Probably Dead'
	END) AS 'Faculty Type', COUNT(*) AS NumberOfFaculties 
	FROM (SELECT (DATEDIFF(DAY, JobBeginDate, GETDATE())/365.25) AS 'ExpInYears' WHERE JobEndDate = NULL)	sub
	GROUP BY (CASE
		WHEN ExpinYears < 1
		THEN 'Fresh'
		WHEN ExpinYears >= 1 AND  ExpinYears < 3
		THEN 'New-ish'
		WHEN ExpinYears >= 3  AND  ExpinYears < 12
		THEN 'Comfortable'
		WHEN ExpinYears >= 12  AND  ExpinYears < 30
		THEN 'Sorta tired'
		ELSE 'Probably Dead'
	END)