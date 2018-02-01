SELECT StdNO, StdFirstName, StdLastName FROM STUDENT 
WHERE StdClass = 'SR' AND StdCity = 'SEATTLE' AND StdGPA BETWEEN 2.7 AND 3.5;


Select * From
	(Select Enrollment.StdNo AS STDNO
		From Enrollment
	Join
		Offering
	ON Enrollment.OfferNo = Offering.OfferNo
	Where Offering.OffYear = 2012 ) T1
where
T1.STDNO NOT IN
		(Select Enrollment.StdNo
		From Enrollment
		Join
		Offering
		ON Enrollment.OfferNo = Offering.OfferNo
		Where Offering.OffYear = 2012 AND Offering.OffTerm = 'FALL' AND Offering.CourseNo Like 'IS%' );

SELECT StdNo, StdFirstName, StdLastName, StdMajor, StdGPA FROM Student
	WHERE StdNo IN
		(SELECT StdNo FROM Enrollment 
			WHERE OfferNO IN
				(SELECT OfferNo FROM OFFERING
					WHERE OffTerm = 'WINTER') )					
ORDER BY StdMajor, StdGPA;


Select Offering.OfferNo, Offering.CourseNo, Course.CrsDesc 
FROM Offering 
JOIN 
	Course 
ON
	Offering.CourseNo = Course.CourseNo
WHERE
		OffTerm = 'SUMMER' AND OffDays LIKE '%W%';


SELECT  
	Offering.CourseNo, Count (DISTINCT Student.StdNo) AS NumberOfISStudents 
FROM 
	Offering, Student, Faculty, Enrollment
WHERE 
	(FacRank != 'PROF') AND (CourseNo LIKE 'IS%') AND (StdMajor = 'IS')
AND 
	Offering.FacNo = Faculty.FacNo
AND 
	Offering.OfferNo = Enrollment.OfferNo
AND 
	Enrollment.StdNo = Student.StdNo
GROUP BY 
	CourseNo 
Having 
	Count(DISTINCT Student.StdNo) >4;


SELECT 
	FacRank, Count(*) AS NOOFNOSUPERVISOR FROM Faculty
WHERE 
	FacSupervisor IS NULL
GROUP BY 
	FacRank;


SELECT  
	Supr.FacNo AS FACNO, count(Subr.FacNo) AS NOOFSUPERVISEES
FROM 
	Faculty Subr, Faculty Supr
WHERE
	 Subr.FacSupervisor = Supr.FacNo
group by 
	Supr.FacNo
order by 
	NOOFSUPERVISEES, Supr.FacNo DESC;



SELECT /* Subr.FacFirstName + ' ' + Subr.FacLastName AS FACULTYNAME,*/
	Supr.FacNo AS FACNO, Supr.FacFirstName + ' ' + Supr.FacLastName AS SUPERVISORNAME, count(Subr.FacNo) AS NOOFSUPERVISEES 
FROM 
	Faculty Subr
RIGHT JOIN
	Faculty Supr
ON 
	Subr.FacSupervisor = Supr.FacNo
GROUP BY 
	Supr.FacNo, /*Subr.FacFirstName , Subr.FacLastName, */Supr.FacFirstName,Supr.FacLastName
ORDER BY 
	Supr.FacFirstName, Supr.FacLastName;




SELECT 
	StdMajor, Count (*) As NUMBEROFSENIORS, MIN(StdGPA) AS MINGPA
FROM
	Student
WHERE 
	StdClass IN ('SR')
GROUP BY 
	StdMajor
HAVING 
	AVG(StdGPA) <= 3.10;


SELECT 
	OffYear, Offterm, Count (OfferNo) AS NUMOFFERINGS, Count(DISTINCT CourseNo) AS NUMCOURSES
FROM 
	Offering
GROUP BY
	OffYear, Offterm;


SELECT  
	T.CourseNo As COURSENO, T.FacFirstName AS FIRSTNAME, T.FacLastName AS LASTNAME, T.STUDENTCOUNT AS STUDENTCOUNT, T.Grade AS AVERAGEGRADE
FROM 
	(
		SELECT 
			Offering.CourseNo , Offering.Offterm, Faculty.FacFirstName, FAculty.FacLastName, Count (Enrollment.StdNo) AS STUDENTCOUNT, AVG (Enrollment.EnrGrade) AS Grade
		FROM 
			Offering
		LEFT JOIN
			Faculty
		ON 
			Offering.FacNo = Faculty.FacNo
		LEFT JOIN
			Enrollment 
		ON
			Offering.OfferNo = Enrollment.OfferNo
		GROUP BY  
			CourseNo, OffTerm, Faculty.FacFirstName, FAculty.FacLastName
	) T
ORDER BY 
	STUDENTCOUNT DESC, 
	CASE WHEN
			FacFirstName IS NOT NULL 
            THEN 0 
          ELSE 1 
     END, 
FacFirstName, FacLastName, Grade;




SELECT 
	Faculty.FacNo AS FACNO, FacFirstName AS FACFIRSTNAME, FacLastName AS FACLASTNAME
FROM 
	Faculty, Offering O1, Offering O2
WHERE 
	Faculty.FacNo = O1.FacNo
AND 
	Faculty.FacSupervisor = O2.FacNo
AND 
	O1.OffYear >= 2012 AND O2.OffYear >= 2012
AND 
	O1.CourseNo = O2.CourseNo
GROUP BY 
	Faculty.FacNo, FacFirstName, FacLastName
ORDER BY 
	FacLastName;


SELECT 
	T.FacNo AS FACNO, T.FacFirst + ' ' + T.FacLast AS FACULTYNAME, T.SupFirst + ' ' + T. SupLast AS SUPERVISORNAME,
	T.CourseNo,
	SUM (T.FacultySTD) AS FACSTDCOUNT, SUM (T.SuperSTD) AS SUPSTDCOUNT
FROM
	(
		SELECT 
			F1.FacNo AS FacNo, F1.FacFirstName AS FacFirst, F1.FacLastName AS FacLast, 
			F2.FacFirstName AS SupFirst, F2.FacLastName AS SupLast, O1.CourseNo AS CourseNo , O1.OfferNo AS FacOfferNo , O2.OfferNo AS SUPOfferNo,
			SUM (CASE  WHEN Enrollment.OfferNo = O1.OfferNo Then 1 else 0 end) AS FacultySTD,
			SUM (CASE  WHEN Enrollment.OfferNo = O2.OfferNo Then 1 else 0 end) AS SuperSTD
		FROM 
			Faculty F1, Faculty F2, Offering O1, Offering O2, Enrollment
		WHERE 
			F1.FacSupervisor = F2.FacNo
		AND 
			F1.FacNo = O1.FacNo
		AND 
			F1.FacSupervisor = O2.FacNo
		AND 
			O1.CourseNo = O2.CourseNo
		GROUP BY 
			O1.CourseNo, O1.OfferNo, O2.OfferNo, F1.FacNo, F1.FacFirstName, F1.FacLastName, 
			F2.FacFirstName, F2.FacLastName 
		)T

GROUP BY 
	T.FacNo, T.FacFirst, T.FacLast, T.SupFirst, T. SupLast, T.CourseNo,  T.FacultySTD, T.SuperSTD
HAVING 
	SUM (T.FacultySTD) > SUM (T.SuperSTD);



SELECT * 
FROM
	(
		SELECT 
			Offering.CourseNo AS CourseNo, Offering.OfferNo AS offerno, count(Enrollment.StdNo) as NOOFSTUDENTS
		FROM 
			Offering
		LEFT JOIN
			Enrollment
		ON 
			Offering.OfferNo = Enrollment.OfferNo
		GROUP BY 
			Offering.CourseNo, Offering.OfferNo) T1
		WHERE 
			T1.NOOFSTUDENTS IN
			(
				SELECT 
					MIN (T2.NOOFSTUDENTS)
				FROM
					(
						SELECT 
							Offering.CourseNo AS CourseNo, Offering.OfferNo AS offerno, count(Enrollment.StdNo) as NOOFSTUDENTS
						FROM 
							Offering
						LEFT JOIN
							Enrollment
						ON 
							Offering.OfferNo = Enrollment.OfferNo
						GROUP BY 
							Offering.CourseNo, Offering.OfferNo
						) T2 
	)




SELECT
	 T2.CourseNo as COURSENO,T2.CrsDesc AS CRSDESC, COUNT( T2.CourseNo) as NOOFTERMS
FROM
	(
		SELECT 
			T1.CourseNo as COURSENO, T1.Year1 as Year3,T1.CourseDesc as CrsDesc 
		FROM 
			(
				SELECT DISTINCT	
					o1.CourseNo, o1.OffYear as Year1, c1.CrsDesc as CourseDesc from Offering o1 
				JOIN 
					Course c1
				ON 
					o1.CourseNo = c1.CourseNo
				WHERE 
					o1.OffTerm = 'summer'
			)T1
		WHERE 
			T1.Year1 
		IN 
			(
				SELECT DISTINCT 
					o1.OffYear as Year2 from Offering o1  where OffTerm = 'summer')
			)T2
GROUP BY 
	T2.COURSENO,T2.CrsDesc
HAVING 
	COUNT( T2.COURSENO) = (select count (DISTINCT o1.OffYear) as Year2 from Offering o1  where OffTerm = 'summer');

SELECT
	Student.stdno AS STDNO, Student.StdFirstName AS STDFIRSTNAME,
	Student.StdLastName AS STDLASTNAME
FROM 
	Student
INNER JOIN
	(
		SELECT 
			count(distinct(Offering.CourseNo)) as ISCOURSE, Enrollment.StdNo 
		FROM 
			Offering 
		INNER JOIN
			Enrollment 
		ON 
			Offering.OfferNo= Enrollment.OfferNo 
		WHERE 
			Offering.CourseNo like 'IS%'
		AND 
			Enrollment.EnrGrade>3
		GROUP BY 
			Enrollment.stdno
		HAVING 
			count(distinct(Offering.CourseNo))=(select count(distinct(Offering.CourseNo)) from offering where CourseNo like 'IS%') 
	) as T
on
	T.stdno= Student.StdNo;


SELECT 
	T3.FACRANK, T3.FACFIRSTNAME, T3.FACFIRSTNAME, T3.SALARY
FROM
	(
		SELECT 
			T2.FacRank as FACRANK , T2.FACFIRSTNAME as FACFIRSTNAME, T2.FACFIRSTNAME as FACLASTNAME, T2.SALARY AS SALARY, MAX(T2.DIFF) AS Diff
		FROM
			(
				SELECT  
					faculty.facrank as FACRANK, faculty.facfirstname AS FACFIRSTNAME, faculty.faclastname as FACLASTNAME, faculty.facsalary AS SALARY, 
					abs(Faculty.FacSalary - T.AVSALARY) as diff
				FROM 
					faculty, 
						(
							SELECT 
								faculty.facrank as FacRank, avg(faculty.facsalary) As AVSALARY 
							FROM 
								faculty
							GROUP BY 
								faculty.facrank
						) T
				WHERE 
					faculty.facrank = T.FacRank
				GROUP BY 
					faculty.facrank, faculty.facfirstname, faculty.faclastname, faculty.facsalary, T.AVSALARY
			) T2

			GROUP BY 
				T2.FacRank, T2.FACFIRSTNAME, T2.FACLASTNAME, T2.SALARY 
	) T3

WHERE 
	T3.DIFF 
IN
	(
		SELECT /*T2.FacRank as FACRANK ,*/ /*T2.FACFIRSTNAME as FACFIRSTNAME, T2.FACFIRSTNAME as FACLASTNAME, T2.SALARY AS SALARY,*/ MAX(T2.DIFF) AS Diff
		FROM
			(
				SELECT  
					faculty.facrank as FACRANK, faculty.facfirstname AS FACFIRSTNAME, faculty.faclastname as FACLASTNAME, faculty.facsalary AS SALARY, 
					abs(Faculty.FacSalary - T.AVSALARY) as diff
				FROM 
					faculty, 
						(
							SELECT 
								faculty.facrank as FacRank, avg(faculty.facsalary) As AVSALARY 
							FROM 
								faculty
							GROUP BY 
								faculty.facrank
						) T
		WHERE 
			faculty.facrank = T.FacRank
		GROUP BY 
			faculty.facrank, faculty.facfirstname, faculty.faclastname, faculty.facsalary, T.AVSALARY
	) T2
GROUP BY 
	T2.FacRank/*, T2.FACFIRSTNAME, T2.FACLASTNAME, T2.SALARY */);



SELECT
	T.STDMAJOR, Student.StdFirstName, STudent.STDLASTNAME /*Student.STDGPA, T.AVGSTDGPA*/
FROM 
	Student
JOIN
	(
		SELECT 
			stdmajor AS STDMAJOR, avg (stdGPA) AS AVGSTDGPA 
		FROM 
			student 
		GROUP BY 
			stdmajor
	) T
ON 
	Student.StDMajor = T.STDMAJOR
WHERE 
	Student.STDGPA <= T.AVGSTDGPA
ORDER BY
	T.STDMAJOR, STudent.STDLASTNAME;


SELECT
	T.ABC AS 'FLOOR', SUM(T.NOOFSECTIONS) AS NOOFSECTIONS
FROM
	(
		SELECT 
			substring(offlocation, 4,1) as ABC, count(offerno) as NOOFSECTIONS
		FROM 
			offering
		GROUP BY 
			offlocation
	) T
GROUP BY 
	T.ABC;


SELECT 
	T.ABC AS 'FLOOR', SUM(T.NOOFSTUDENTS) AS NOOFSTUDENTS
FROM
	(
		SELECT 
			substring(offering.offlocation, 4,1) as ABC, count(Enrollment.StdNo) as NOOFSTUDENTS
		FROM 
			offering
		LEFT JOIN 
			Enrollment
		ON 
			offering.offerno = enrollment.offerno
		GROUP BY 
			offlocation
	) T
GROUP BY 
	T.ABC;

