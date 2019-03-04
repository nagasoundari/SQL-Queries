--1) Write the SQL to determine which students took the most Biology credits during 1980's.

SELECT TOP 1 WITH TIES maxcred.StudentID, MAX(maxcred.TotalCredits) FROM
(SELECT ST.StudentID, SUM(CR.Credits) as TotalCredits
	FROM tblSTUDENT ST
	JOIN tblCLASS_LIST CLL ON CLL.StudentID = ST.StudentID
	JOIN tblCLASS CL ON CL.ClassID = CLL.ClassID
	JOIN tblCOURSE CR ON CR.CourseID = CL.CourseID
	JOIN tblDEPARTMENT D ON D.DeptID = CR.DeptID
	WHERE D.DeptName like '%Biology%' AND CL.YEAR >= 1980 AND CL.YEAR <= 1989
	GROUP BY ST.StudentID) maxcred
	GROUP BY StudentID
	ORDER BY MAX(maxcred.TotalCredits) DESC

---The Student with ID 152550 had taken the most Biology credits during 1980's and is 19 credits.



--2) Write the SQL to determine the 3 colleges that had lowest average grade awarded during 1930's. 

SELECT TOP 3 CO.CollegeID, CO.CollegeName, AVG(CLL.Grade)
	FROM tblCOLLEGE CO
	JOIN tblDEPARTMENT D ON D.CollegeID = CO.CollegeID
	JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
	JOIN tblCLASS CL ON CL.CourseID = CR.CourseID
	JOIN tblCLASS_LIST CLL ON CLL.ClassID = CL.ClassID
	WHERE CL.YEAR >= 1930 AND CL.YEAR <= 1939
	GROUP BY CO.CollegeID, CO.CollegeName
	ORDER BY AVG(CLL.Grade)

--- The three colleges that had awarded lowest average grade awrded is Public Affairs, Social Work and Engineering.		




--3) Write the SQL to determine which colleges have offered at least 800 classes of '400-level' during Spring quarters since 1983
-- that also had at least 10,000 students registered for a class Winter 1989?
	SELECT class.CollegeID, class.CollegeName, class.NoOfClasses, students.NoOfStudents
	FROM
	
	(SELECT CO.CollegeID, CO.CollegeName, COUNT(CL.ClassID) as NoOfClasses
	FROM tblCOLLEGE CO
	JOIN tblDEPARTMENT D ON D.CollegeID = CO.CollegeID
	JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
	JOIN tblCLASS CL ON CL.CourseID = CR.CourseID
	JOIN tblQUARTER Q ON Q.QuarterID = CL.QuarterID
	WHERE CR.CourseNumber >= 400 AND CR.CourseNumber < 500 AND CL.YEAR >= 1983 AND Q.QuarterName = 'Spring'
	GROUP BY CO.CollegeID, CO.CollegeName
	HAVING COUNT(CL.ClassID) >= 800) class

	JOIN

	(SELECT CO.CollegeID, CO.CollegeName, COUNT(*) as NoOfStudents
	FROM tblCOLLEGE CO
	JOIN tblDEPARTMENT D ON D.CollegeID = CO.CollegeID
	JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
	JOIN tblCLASS CL ON CL.CourseID = CR.CourseID
	JOIN tblQUARTER Q ON Q.QuarterID = CL.QuarterID
	JOIN tblCLASS_LIST CLL ON CLL.ClassID = CL.ClassID
	JOIN tblSTUDENT ST ON ST.StudentID = CLL.StudentID
	WHERE CL.YEAR = 1989 AND Q.QuarterName = 'Winter'
	GROUP BY CO.CollegeID, CO.CollegeName
	HAVING COUNT(*) >= 10000) students

	ON class.CollegeID = students.CollegeID

---- The colleges that satisfy both the conditions are Business, Environment, Arts and Sciences, and Medicine.




--4) Write the SQL to determine the Locations on campus that offered no more than 80 Mathematics courses during the 1940's.

SELECT L.LocationID, L.LocationName, COUNT(*)
	FROM tblDEPARTMENT D 
	JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
	JOIN tblCLASS CL ON CL.CourseID = CR.CourseID
	JOIN tblCLASSROOM CLR ON CLR.ClassroomID = CL.ClassroomID
	JOIN tblBUILDING B ON B.BuildingID = CLR.BuildingID
	JOIN tblLOCATION L ON L.LocationID = B.LocationID
	WHERE D.DeptName = 'Mathematics' AND CL.YEAR >= 1940 AND CL.YEAR <= 1949
	GROUP BY L.LocationID, L.LocationName
	HAVING COUNT(*) <= 80

---The Locations on campus that offered no more than 80 Mathematics courses during the 1940's are Rainier Vista, 
--Liberal Arts Quadrangle ('The Quad'), Central Plaza ('Red Square'), Memorial Way and West Campus.




--5) Write the SQL to determine the Locations on campus that offered at least 20 History courses during the 1970's 

SELECT L.LocationID, L.LocationName, COUNT(*)
	FROM tblDEPARTMENT D 
	JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
	JOIN tblCLASS CL ON CL.CourseID = CR.CourseID
	JOIN tblCLASSROOM CLR ON CLR.ClassroomID = CL.ClassroomID
	JOIN tblBUILDING B ON B.BuildingID = CLR.BuildingID
	JOIN tblLOCATION L ON L.LocationID = B.LocationID
	WHERE D.DeptName = 'History' AND CL.YEAR >= 1970 AND CL.YEAR <= 1979
	GROUP BY L.LocationID, L.LocationName
	HAVING COUNT(*) >= 20
	
---- The Locations on campus that offered at least 20 History courses during the 1970's are Rainier Vista, Stevens Way, West Campus and 
---South Campus.





--6). Write the SQL to return the Locations that meet all conditions in questions #4 and #5 above; 
--try and return BOTH counts in a single query(!!).
SELECT math.LocationName, math.NoOfMathsClasses, hist.NoOfHistoryClasses
FROM
	
	(SELECT L.LocationID, L.LocationName, COUNT(*) as NoOfMathsClasses
	FROM tblDEPARTMENT D 
	JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
	JOIN tblCLASS CL ON CL.CourseID = CR.CourseID
	JOIN tblCLASSROOM CLR ON CLR.ClassroomID = CL.ClassroomID
	JOIN tblBUILDING B ON B.BuildingID = CLR.BuildingID
	JOIN tblLOCATION L ON L.LocationID = B.LocationID
	WHERE D.DeptName = 'Mathematics' AND CL.YEAR >= 1940 AND CL.YEAR <= 1949
	GROUP BY L.LocationID, L.LocationName
	HAVING COUNT(*) <= 80) math

	JOIN

	(SELECT L.LocationID, L.LocationName, COUNT(*) as NoOfHistoryClasses
	FROM tblDEPARTMENT D 
	JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
	JOIN tblCLASS CL ON CL.CourseID = CR.CourseID
	JOIN tblCLASSROOM CLR ON CLR.ClassroomID = CL.ClassroomID
	JOIN tblBUILDING B ON B.BuildingID = CLR.BuildingID
	JOIN tblLOCATION L ON L.LocationID = B.LocationID
	WHERE D.DeptName = 'History' AND CL.YEAR >= 1970 AND CL.YEAR <= 1979
	GROUP BY L.LocationID, L.LocationName
	HAVING COUNT(*) >= 20) hist

	ON math.LocationName = hist.LocationName
	

---- The locations that satisfy noth the conditions in question 4 and 5 are Rainier Vista and West Campus with 23, 22 classes 
--and 29, 37 history classes respectively


