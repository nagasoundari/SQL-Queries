  ------//***Registration Date set as 2019-02-01****///-----
  
-----1) Which colleges have at least 1 department that meet the following two conditions:
	--a) have at least 4 current staff that have been in the same position for 2 years
	--b) have had more than 10,000 students register for one course since 2007.

SELECT parta.CollegeID, parta.CollegeName FROM
--a) have at least 4 current staff that have been in the same position for 2 years
(SELECT staff1.CollegeName, staff1.CollegeID, COUNT(*) as NumOfStaffs FROM
(SELECT staff.DeptID, staff.Num, coll.CollegeID, coll.DeptName, coll.CollegeName FROM 
(SELECT Sub.DeptID, COUNT(*) as Num
FROM 
(SELECT * 
FROM [UNIVERSITY].dbo.tblSTAFF_POSITION 
WHERE EndDate > '2019-02-01' 
AND datediff(Year, BeginDate, EndDate) > 2) Sub
GROUP BY Sub.DeptID 
HAVING COUNT(*) >= 4) staff
JOIN
(SELECT D.DeptID, D.DeptName, C.CollegeID, C.CollegeName FROM
tblDEPARTMENT D
JOIN tblCOLLEGE C ON C.CollegeID = D.CollegeID) coll
ON staff.DeptID = coll.DeptID) staff1
GROUP BY staff1.CollegeName, staff1.CollegeID
HAVING COUNT(*) >= 1) parta

INNER JOIN
--b) have had more than 10,000 students register for one course since 2007.
(SELECT college.CollegeID, college.CollegeName, COUNT(*) as NumOfDepts FROM
(SELECT deptCount.DeptID, deptCount.NoOfStuds, DP.CollegeID, COLL.CollegeName FROM
(SELECT dept.DeptID, SUM(dept.NumOfStud) as NoOfStuds FROM
(SELECT course.CourseID, course.DeptID, SUM(course.NoOfStudents) as NumOfStud FROM
(SELECT C.ClassID, C.CourseID, class.NoOfStudents, class.DeptID FROM tblCLASS C
JOIN 
(SELECT sub.ClassID, sub.DeptID, COUNT(StudentID) AS NoOfStudents FROM
(SELECT S.StudentID, CL.ClassID, CLL.RegistrationDate, CL.CourseID, CR.DeptID  FROM 
tblSTUDENT S 
JOIN tblCLASS_LIST CLL ON CLL.StudentID = S.StudentID
JOIN tblCLASS CL ON CL.ClassID = CLL.ClassID
JOIN tblCOURSE CR ON CR.CourseID = CL.CourseID
WHERE CLL.RegistrationDate < '2019-02-01' AND CLL.RegistrationDate > '2007-01-01') sub
GROUP BY sub.ClassID, sub.DeptID) class 

ON class.ClassID = C.ClassID)  course
GROUP BY course.CourseID, course.DeptID) dept
GROUP BY dept.DeptID
HAVING SUM(dept.NumOfStud) > 10000) deptCount
LEFT JOIN tblDEPARTMENT DP ON DP.DeptID = deptCount.DeptID
LEFT JOIN tblCOLLEGE COLL ON COLL.CollegeID = DP.CollegeID) college
GROUP BY college.CollegeID, college.CollegeName
HAVING COUNT(*) >= 1) partb
ON parta.CollegeID = partb.CollegeID


---There are 15 colleges in total that has atleast one department that met both the conditions

-------------------------------------------------------------------------------------------------------------------------------------------

--2) Which Colleges have held at least 4 classes in buildings located on 'Stevens Way' in the 1980's 
--that have also had fewer than 32,000 students make a 4.0 since 1990?
SELECT parta.CollegeID, parta.CollegeName FROM
(SELECT sub.CollegeID, sub.CollegeName, COUNT(*) AS NumOfClass 
FROM
(SELECT CO.CollegeID, CO.CollegeName, CR.DeptID, CL.CourseID, CL.YEAR, CLR.ClassroomID, B.BuildingID, L.LocationID, L.LocationName 
FROM tblCOLLEGE CO
JOIN tblDEPARTMENT D ON CO.CollegeID = D.CollegeID
JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
JOIN tblCLASS CL ON CL.CourseID = CR.CourseID
JOIN tblCLASSROOM CLR ON CLR.ClassroomID = CL.ClassroomID
JOIN tblBUILDING B ON B.BuildingID = CLR.BuildingID
JOIN tblLOCATION L ON L.LocationID = B.LocationID
WHERE CL.YEAR >= 1980 AND CL.YEAR <= 1989 AND L.LocationName = 'Stevens Way') sub
GROUP BY sub.CollegeID, sub.CollegeName
HAVING COUNT(*) > 4) parta

INNER JOIN

(SELECT sub.CollegeID, sub.CollegeName, COUNT(*) AS NumOfStuds FROM
(SELECT CO.CollegeID, CO.CollegeName, D.DeptID, CR.CourseID, CL.ClassID, CL.YEAR, CLL.Grade, CLL.RegistrationDate, CLL.StudentID FROM
tblCOLLEGE CO 
JOIN tblDEPARTMENT D ON CO.CollegeID = D.CollegeID
JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
JOIN tblCLASS CL ON CL.CourseID = CR.CourseID
JOIN tblCLASS_LIST CLL ON CLL.ClassID = CL.ClassID
WHERE CLL.Grade = 4.0 AND CL.YEAR > 1990 AND CLL.RegistrationDate < '2019-02-01') sub
GROUP BY sub.CollegeID, sub.CollegeName) partb
ON parta.CollegeID = partb.CollegeID

--There are 15 colleges that satisfy the conditions.

-------------------------------------------------------------------------------------------------------------------------------------------

--3) Which students have taken more than one class in an auditorium and have also completed fewer than 3 classes with a 3.9 or above?
   
  SELECT Auditorium.StudentID, Auditorium.NumOfClassInAuditorium, Grade.NumOfClassGrade FROM 
  (SELECT new.StudentID, COUNT(*) as NumOfClassInAuditorium FROM
  (SELECT ST.StudentID, CLL.RegistrationDate 
	FROM tblCLASSROOM_TYPE CRT
	JOIN tblCLASSROOM CR ON CR.ClassroomTypeID = CRT.ClassroomTypeID
	JOIN tblCLASS CL ON CL.ClassroomID = CR.ClassroomID
	JOIN tblCLASS_LIST CLL ON CLL.ClassID = CL.ClassID
	JOIN tblSTUDENT ST ON ST.StudentID = CLL.StudentID
	WHERE ClassroomTypeName = 'Auditorium' AND CLL.RegistrationDate < '2019-02-01') new
	GROUP BY new.StudentID
	HAVING COUNT(*) > 1) Auditorium

	INNER JOIN
	
	(SELECT sub.StudentID, COUNT(*) as NumOfClassGrade FROM 
	(SELECT * FROM [UNIVERSITY].dbo.tblCLASS_LIST
	WHERE Grade >= 3.9 AND RegistrationDate < '2019-02-01') sub
	GROUP BY sub.StudentID
	HAVING COUNT(*) < 3) Grade

	ON Auditorium.StudentID = Grade.StudentID

--The number of students who have taken more than one class in an auditorium and have also completed fewer than 3 classes with a 3.9 or above is 280.

-------------------------------------------------------------------------------------------------------------------------------------------

--4) Write SQL query to determine the number of students who have received a grade of 3.5 or greater for a class 
--from the College of Arts and Sciences since 1976.

SELECT COUNT(DISTINCT StudentID) as NumOfStudents
FROM tblCLASS_LIST CLL
JOIN tblCLASS CL ON CLL.ClassID = CL.ClassID
JOIN tblCOURSE CR ON CR.CourseID = CL.CourseID
JOIN tblDEPARTMENT D ON D.DeptID = CR.DeptID
JOIN tblCOLLEGE C ON C.CollegeID = D.CollegeID
WHERE CollegeName = 'Arts and Sciences' AND YEAR >= 1976 AND Grade >= 3.5 AND CLL.RegistrationDate < '2019-02-01'

--The number of students satisfying these conditions are 26635.

-------------------------------------------------------------------------------------------------------------------------------------------

--5) Write the SQL code to determine the 5 most popular courses by number of registrations before 1986.
SELECT TOP 5 sub.CourseID, sub.CourseName, COUNT (*) as NumOfReg FROM 
(SELECT CLL.ClassID, CLL.StudentID, CLL.RegistrationDate, CLL.Grade, CL.CourseID, CL.YEAR, CR.CourseName
FROM tblCLASS_LIST CLL
JOIN tblCLASS CL ON CLL.ClassID = CL.ClassID
JOIN tblCOURSE CR ON CR.CourseID = CL.CourseID
WHERE RegistrationDate < '1986-01-01') sub
GROUP BY sub.CourseID, sub.CourseName
ORDER BY NumOfReg DESC

--The 5 most popular courses before 1986 were AMATH666, RADGY355, PEDO652, EDPSY338 and FIN433 respectively.

-------------------------------------------------------------------------------------------------------------------------------------------

--6) Write the SQL code to determine which states have had at least 100 students 
--who have taken more than 2 classes from the Information School and have also 
--completed more than 3 classes from School of Medicine. 
SELECT totsub.StudentPermState, COUNT (*) as NumOfStudents FROM
(SELECT Info.StudentID, Info.StudentPermState 
FROM
(SELECT sub.StudentID, sub.StudentPermState, sub.CollegeName, COUNT (*) as NumOfIS FROM
(SELECT CO.CollegeID, CO.CollegeName, D.DeptID, CR.CourseID, CL.ClassID, S.StudentID, S.StudentPermState
FROM tblCOLLEGE CO
JOIN tblDEPARTMENT D ON CO.CollegeID = D.CollegeID 
JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
JOIN tblCLASS CL ON CL.CourseID = CR.CourseID
JOIN tblCLASS_LIST CLL ON CLL.ClassID = CL.ClassID
JOIN tblSTUDENT S ON S.StudentID = CLL.StudentID
WHERE CLL.RegistrationDate < '2019-02-01') sub
GROUP BY sub.StudentID, sub.CollegeName, sub.StudentPermState
HAVING sub.CollegeName = 'Information School' AND COUNT (*) > 2) Info

INNER JOIN

(SELECT sub.StudentID, sub.StudentPermState, sub.CollegeName, COUNT (*) as NumOfMed FROM
(SELECT CO.CollegeID, CO.CollegeName, D.DeptID, CR.CourseID, CL.ClassID, S.StudentID, S.StudentPermState
FROM tblCOLLEGE CO
JOIN tblDEPARTMENT D ON CO.CollegeID = D.CollegeID 
JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
JOIN tblCLASS CL ON CL.CourseID = CR.CourseID
JOIN tblCLASS_LIST CLL ON CLL.ClassID = CL.ClassID
JOIN tblSTUDENT S ON S.StudentID = CLL.StudentID
WHERE CLL.RegistrationDate < '2019-02-01') sub
GROUP BY sub.StudentID, sub.CollegeName, sub.StudentPermState
HAVING sub.CollegeName = 'Medicine' AND COUNT (*) > 3) Medicine
ON Info.StudentID = Medicine.StudentID) totsub
GROUP BY totsub.StudentPermState
HAVING COUNT (*) >= 100

--There are 30 states that has atleast 100 students satisfying the conditions.































