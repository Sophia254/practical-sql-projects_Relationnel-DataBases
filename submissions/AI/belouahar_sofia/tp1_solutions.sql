DROP DATABASE IF EXISTS university_db;
CREATE DATABASE university_db;
USE university_db;


CREATE TABLE departments(
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    building VARCHAR(50) NOT NULL,
    budget DECIMAL(12, 2) NOT NULL,
    department_head VARCHAR(100) NOT NULL,
    creation_date DATE NOT NULL

);

CREATE TABLE professors (
    professor_id INT PRIMARY KEY AUTO_INCREMENT,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    department_id INT,
    CONSTRAINT fk_prof_department
      FOREIGN KEY (department_id)
      REFERENCES departments(department_id)
      
);

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_number VARCHAR(20) NOT NULL UNIQUE,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100) NOT NULL UNIQUE,
    address TEXT,
    enrollment_date DATE DEFAULT (CURRENT_DATE()),
    level VARCHAR(20) CHECK (level IN ('L1', 'L2', 'L3', 'M1', 'M2')),
    department_id INT,
    CONSTRAINT fk_student_department
      FOREIGN KEY (department_id)
      REFERENCES departments(department_id)
      ON DELETE SET NULL
      ON UPDATE CASCADE
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(10) NOT NULL UNIQUE,
    course_name VARCHAR(150) NOT NULL,
    description TEXT,
    credits INT CHECK (credits > 0),
    semester INT CHECK (semester IN (1, 2)),   
    professor_id INT, 
    department_id INT,
    max_capacity INT DEFAULT 30,

    CONSTRAINT fk_course_professor
      FOREIGN KEY (professor_id)
      REFERENCES professors(professor_id)
      ON DELETE SET NULL
      ON UPDATE CASCADE,

    CONSTRAINT fk_course_department
      FOREIGN KEY (department_id)
      REFERENCES departments(department_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE()),
    academic_year VARCHAR(9) CHECK (academic_year REGEXP '^[0-9]{4}-[0-9]{4}$'),
    status VARCHAR(20) DEFAULT 'In Progress' CHECK (status IN ('In Progress','Passed','Failed','Dropped')),
    
    
    CONSTRAINT fk_enrollment_student
      FOREIGN KEY (student_id)
      REFERENCES students(student_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
    CONSTRAINT uq_enrollment UNIQUE (student_id, course_id, academic_year),
    CONSTRAINT fk_enrollment_course
      FOREIGN KEY (course_id)
      REFERENCES courses(course_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

CREATE TABLE grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id INT NOT NULL,
    evaluation_type VARCHAR(30) CHECK (evaluation_type IN ('Exam', 'Assignment', 'Project', 'Lab'))   ,
    grade DECIMAL(5, 2) CHECK (grade >= 0 AND grade <= 20),
    coefficient DECIMAL(3, 2) DEFAULT 1.00 CHECK (coefficient > 0),
    COMMENTS TEXT,
    evaluation_date DATE DEFAULT (CURRENT_DATE),
    
    CONSTRAINT fk_grade_enrollment
      FOREIGN KEY (enrollment_id)
      REFERENCES enrollments(enrollment_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
); 

CREATE INDEX idx_student_department ON students(department_id);
CREATE INDEX idx_course_professor ON courses(professor_id);
CREATE INDEX idx_enrollment_student ON enrollments(student_id);
CREATE INDEX idx_enrollment_course ON enrollments(course_id);
CREATE INDEX idx_grades_enrollment ON grades(enrollment_id);


INSERT INTO departments (department_name, building, budget, department_head, creation_date) VALUES
('Computer Science', 'Building A', 500000.00, 'Dr. Smith', '2000-01-15'),
('Mathematics', 'Building B', 350000.00, 'Dr. Johnson', '1995-09-01'),
('Civil Engineering','Building D',600000,'Dr. White','2006-09-01'),
('Physics', 'Building C', 400000.00, 'Dr. Brown', '2010-05-20');

INSERT INTO professors (last_name, first_name, email, phone, hire_date, salary, specialization, department_id) VALUES
('Smith', 'John', 'john.smith@university.edu', '55512384', '2010-08-15', 75000.00, 'Artificial Intelligence', 1),
('Wilson', 'Mark', 'mark.wilson@uni.com', '555666777','2017-09-01',72000,'Cybersecurity', 1),
('Davis', 'Sarah', 'sarah.davis@uni.com','987654321', '2016-09-01',68000,'Databases', 1),
('Johnson', 'Mary', 'mary.johnson@university.edu', '555561678', '2012-03-22', 82000.00, 'Statistics', 2),
('Brown', 'Robert', 'robert.brown@university.edu', '555901234', '2019-11-30', 78000.00, 'Quantum Physics', 4),
('Thomas','Linda','l.thomas@uni.com','222333444', '2012-09-01',75000,'Structural Engineering', 3);

INSERT INTO students (student_number, last_name, first_name, date_of_birth, phone, email, address, level, department_id) VALUES
('S1001','Ali','Karim','2003-05-10', '85648959','ali@uni.com','Algiers', 'L2', 1),
('S1002','Sara','Benali','2002-07-12','85648958','sara@uni.com', 'Constantine', 'L3', 1),
('S1003','Omar','Haddad','2001-03-15','585648957','omar@uni.com','Oran', 'M1', 2),
('S1004','Nina','Rahim','2003-09-20','585648956','nina@uni.com','Tizi Ouzou', 'L2', 3),
('S1005','Yassine','Khaled','2002-11-30','585648955','yassine@uni.com','Annaba', 'L3', 4),
('S1006','Lina','Amir','2001-01-25','585648954','lina@uni.com','Bejaia', 'M1', 1),
('S1007','Adam','Nouri','2003-04-18', '585648953', 'adam@uni.com', 'Annaba', 'L2', 2),
('S1008','Maya','Zidane','2002-08-08','85648952','maya@uni.com','Bejaia', 'L3', 3);

INSERT INTO courses (course_code, course_name, description, credits, semester, professor_id, department_id, max_capacity) VALUES 
('CS101', 'Introduction to Computer Science', 'Basic concepts of computer science and programming.', 3, '1', 1, 1, 50), 
('CS201', 'Data Structures', 'Study of data structures and algorithms.', 4, '2', 2, 1, 40), 
('CS301', 'Database Systems', 'Design and implementation of database systems.', 6, '1', 3, 1, 35), 
('MATH101', 'Calculus I', 'Differential and integral calculus.', 4, '1', 4, 2, 60),
('PHYS101', 'General Physics I', 'Fundamental principles of physics.', 4, '1', 5, 4, 45), 
('CIVIL101','Structural Analysis','Introduction to structural analysis methods.',3,'2',6,3,30),
('ENG101','English for Engineers','English language skills for engineering students.',2,'1',NULL, NULL, 100);

 
  INSERT INTO enrollments (student_id, course_id, enrollment_date, academic_year, status) VALUES
(1, 1,'2023-09-01','2023-2024', 'Passed'),
(1, 2,'2023-09-01','2023-2024', 'Passed'), 
(2, 1,'2023-09-01','2023-2024', 'Failed'), 
(2, 3,'2023-09-01','2023-2024', 'Passed'), 
(3, 4,'2023-09-01','2023-2024', 'Passed'),
(4, 6,'2023-09-01','2023-2024', 'Passed'),
(5, 5,'2023-09-01','2023-2024', 'Passed'), 
(6, 1,'2023-09-01','2023-2024', 'Passed'),
(7, 4,'2023-09-01','2023-2024', 'Passed'), 
(8, 6,'2023-09-01','2023-2024', 'Failed'),
(8, 5,'2023-09-01','2023-2024', 'Failed'),
(7, 2,'2023-09-01','2023-2024', 'Failed'),
(6, 3,'2023-09-01','2023-2024', 'Passed'), 
(5, 1,'2023-09-01','2023-2024', 'Failed'), 
(4, 4,'2023-09-01','2023-2024', 'Failed'),
(3, 2,'2023-09-01','2023-2024', 'Failed'), 
(2, 5,'2023-09-01','2023-2024', 'Failed'), 
(1, 6,'2023-09-01','2023-2024', 'Failed');

INSERT INTO grades (enrollment_id, evaluation_type, grade, coefficient, comments, evaluation_date) VALUES
(1, 'Exam', 15.5, 0.7, 'Good performance', '2024-12-15'), 
(1, 'Assignment', 18.0, 0.3, 'Excellent work', '2024-11-15'), 
(2, 'Exam', 12.0, 0.7, 'Needs improvement','2024-12-15'), 
(2, 'Project', 14.5, 0.3, 'Satisfactory', '2024-12-20'), 
(3, 'Exam', 16.0, 0.7, 'Well done', '2024-12-15'), 
(3, 'Lab', 17.5, 0.3, 'Great effort', '2024-11-20'), 
(4, 'Exam', 10.0, 0.7, 'Below average', '2024-12-15'), 
(4, 'Assignment', 13.0, 0.3, 'Fair work', '2024-11-15'), 
(5, 'Exam', 17.5, 0.7, 'Outstanding', '2024-12-15'), 
(5, 'Project', 18.0, 0.3, 'Excellent project', '2024-12-20'),
(6, 'Exam', 13.0, 0.7, 'Good job', '2024-12-15'), 
(6, 'Assignment', 16.5, 0.3, 'Nice work','2024-11-15'), 
(7, 'Exam', 10.0, 0.7, 'Needs significant improvement', '2024-12-15'), 
(7, 'Lab', 11.0, 0.3, 'Satisfactory effort', '2024-11-20'), 
(8, 'Exam', 13.5, 0.7, 'Decent performance', '2024-12-15'), 
(8, 'Project', 15.0, 0.3, 'Good project', '2024-12-20');

-- ========== PART 1: BASIC QUERIES (Q1-Q5) ==========

-- Q1. List all students with their main information (name, email, level)
SELECT last_name, first_name, email, level
FROM students;

-- Q2. Display all professors from the Computer Science department
SELECT last_name, first_name, email, specialization
FROM professors p
JOIN departments d ON p.department_id = d.department_id
WHERE d.department_name = 'Computer Science';

-- Q3. Find all courses with more than 5 credits
SELECT course_code, course_name, credits        
FROM courses
WHERE credits > 5;

-- Q4. List students enrolled in L3 level
SELECT student_number, last_name, first_name, email
FROM students
WHERE level = 'L3';

-- Q5. Display courses from semester 1
SELECT course_code, course_name, credits, semester          
FROM courses
WHERE semester = 1; 

-- ========== PART 2: QUERIES WITH JOINS (Q6-Q10) ==========

-- Q6. Display all courses with the professor's name
SELECT c.course_code, 
       c.course_name, 
       CONCAT(p.last_name, ' ', p.first_name) AS professor_name
FROM courses c
LEFT JOIN professors p ON c.professor_id = p.professor_id;

-- Q7. List all enrollments with student name and course name
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name,
       c.course_name,
       e.enrollment_date,
       e.status
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

-- Q8. Display students with their department name
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name,
       d.department_name,
       s.level 
FROM students s
JOIN departments d ON s.department_id = d.department_id;

-- Q9. List grades with student name, course name, and grade obtained
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name,
       c.course_name,
       g.evaluation_type,
       g.grade
FROM grades g
JOIN enrollments e ON g.enrollment_id = e.enrollment_id
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

-- Q10. Display professors with the number of courses they teach
SELECT CONCAT(p.last_name, ' ', p.first_name) AS professor_name,
       COUNT(c.course_id) AS number_of_courses
FROM professors p
LEFT JOIN courses c ON p.professor_id = c.professor_id
GROUP BY p.professor_id, p.last_name, p.first_name;

-- ========== PART 3: AGGREGATE FUNCTIONS (Q11-Q15) ==========

-- Q11. Calculate the overall average grade for each student
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name,
       SUM(g.grade * g.coefficient) / SUM(g.coefficient) AS average_grade
FROM grades g
JOIN enrollments e ON g.enrollment_id = e.enrollment_id 
JOIN students s ON e.student_id = s.student_id
GROUP BY s.student_id, s.last_name, s.first_name;

-- Q12. Count the number of students per department
SELECT d.department_name,
       COUNT(s.student_id) AS student_count     
FROM departments d
LEFT JOIN students s ON d.department_id = s.department_id       
GROUP BY d.department_id, d.department_name;

-- Q13. Calculate the total budget of all departments
SELECT SUM(budget) AS total_budget_of_departments  
FROM departments;   
-- Q14. Find the total number of courses per department
SELECT d.department_name,
       COUNT(c.course_id) AS course_count   
FROM departments d
LEFT JOIN courses c ON d.department_id = c.department_id
GROUP BY d.department_id, d.department_name;

-- Q15. Calculate the average salary of professors per department
SELECT d.department_name,
       AVG(p.salary) AS average_salary  
FROM departments d
LEFT JOIN professors p ON d.department_id = p.department_id 
GROUP BY d.department_id, d.department_name;

-- ========== PART 4: ADVANCED QUERIES (Q16-Q20) ==========

-- Q16. Find the top 3 students with the best averages
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name,
       SUM(g.grade * g.coefficient) / SUM(g.coefficient) AS average_grade
FROM grades g
JOIN enrollments e ON g.enrollment_id = e.enrollment_id
JOIN students s ON e.student_id = s.student_id
GROUP BY s.student_id, s.last_name, s.first_name
ORDER BY average_grade DESC
LIMIT 3;

-- Q17. List courses with no enrolled students
SELECT c.course_name
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.course_id IS NULL;

-- Q18. Display students who have passed all their courses (status = 'Passed')
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name,
       COUNT(e.enrollment_id) AS passed_courses_count
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
WHERE e.status = 'Passed'
GROUP BY s.student_id, s.last_name, s.first_name
HAVING COUNT(e.enrollment_id) = (
    SELECT COUNT(*) FROM enrollments e2 WHERE e2.student_id = s.student_id
);

-- Q19. Find professors who teach more than 2 courses
SELECT CONCAT(p.last_name, ' ', p.first_name) AS professor_name,
       COUNT(c.course_id) AS courses_taught
FROM professors p
JOIN courses c ON p.professor_id = c.professor_id
GROUP BY p.professor_id, p.last_name, p.first_name
HAVING COUNT(c.course_id) > 2;


-- Q20. List students enrolled in more than 2 courses
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name,
       COUNT(e.course_id) AS courses_enrolled
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.last_name, s.first_name
HAVING COUNT(e.course_id) > 2;

-- ======= PART 5: SUBQUERIES (Q21-Q25) ==========

-- Q21. Find students with an average higher than their department's average
SELECT student_data.student_name,
       student_data.student_avg,
       dept_data.department_avg
FROM (
    SELECT s.student_id,
           s.department_id,
           CONCAT(s.last_name, ' ', s.first_name) AS student_name,
           SUM(g.grade * g.coefficient) / SUM(g.coefficient) AS student_avg
    FROM students s
    JOIN enrollments e ON s.student_id = e.student_id
    JOIN grades g ON e.enrollment_id = g.enrollment_id
    GROUP BY s.student_id, s.department_id
) AS student_data
JOIN (
    SELECT dept_students.department_id,
           AVG(dept_students.student_avg) AS department_avg
    FROM (
        SELECT s.student_id,
               s.department_id,
               SUM(g.grade * g.coefficient) / SUM(g.coefficient) AS student_avg
        FROM students s
        JOIN enrollments e ON s.student_id = e.student_id
        JOIN grades g ON e.enrollment_id = g.enrollment_id
        GROUP BY s.student_id, s.department_id
    ) AS dept_students
    GROUP BY dept_students.department_id
) AS dept_data
ON student_data.department_id = dept_data.department_id
WHERE student_data.student_avg > dept_data.department_avg;



-- Q22. List courses with more enrollments than the average number of enrollments
SELECT course_name,
       (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = c.course_id) AS enrollment_count
FROM courses c
WHERE (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = c.course_id) >
      (SELECT AVG(enrollment_count) FROM (
          SELECT COUNT(*) AS enrollment_count
          FROM enrollments e2
          GROUP BY e2.course_id
      ) AS subquery);   
-- Q23. Display professors from the department with the highest budget
SELECT CONCAT(p.last_name, ' ', p.first_name) AS professor_name,
       d.department_name,
       d.budget 
FROM professors p
JOIN departments d ON p.department_id = d.department_id
WHERE d.budget = (SELECT MAX(budget) FROM departments);

-- Q24. Find students with no grades recorded
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name,
       s.email
FROM students s
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments e
    JOIN grades g ON e.enrollment_id = g.enrollment_id
    WHERE e.student_id = s.student_id
);


-- Q25. List departments with more students than the average
SELECT department_name,
       student_count
FROM (
    SELECT d.department_name,
           COUNT(s.student_id) AS student_count     
    FROM departments d
    LEFT JOIN students s ON d.department_id = s.department_id   
    GROUP BY d.department_id, d.department_name
) AS dept_counts
WHERE student_count > (SELECT AVG(student_count) FROM (
    SELECT COUNT(s2.student_id) AS student_count
    FROM departments d2
    LEFT JOIN students s2 ON d2.department_id = s2.department_id
    GROUP BY d2.department_id
) AS avg_counts);

-- ========== PART 6: DATA MANIPULATION (Q26-Q30) ==========

-- Q26. Calculate the pass rate per course (grades >= 10/20)
SELECT c.course_name,
       COUNT(g.grade_id) AS total_grades,
       SUM(CASE WHEN g.grade >= 10 THEN 1 ELSE 0 END) AS passed_grades,
       (SUM(CASE WHEN g.grade >= 10 THEN 1 ELSE 0 END) * 100.0 / COUNT(g.grade_id)) AS pass_rate_percentage
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
JOIN grades g ON e.enrollment_id = g.enrollment_id
GROUP BY c.course_id, c.course_name;

-- Q27. Display student ranking by descending average
SELECT RANK() OVER (ORDER BY AVG(g.grade * g.coefficient) DESC) AS student_rank, 
       CONCAT(s.last_name, ' ', s.first_name) AS student_name, 
       SUM(g.grade * g.coefficient) / SUM(g.coefficient) AS average_grade 
FROM grades g 
JOIN enrollments e ON g.enrollment_id = e.enrollment_id 
JOIN students s ON e.student_id = s.student_id 
GROUP BY s.student_id, s.last_name, s.first_name 
ORDER BY average_grade DESC;


-- Q28. Generate a report card for student with student_id = 1
SELECT c.course_name,
        g.evaluation_type, 
        g.grade, 
        g.coefficient, 
        (g.grade * g.coefficient) AS weighted_grade 
FROM grades g 
JOIN enrollments e ON g.enrollment_id = e.enrollment_id 
JOIN courses c ON e.course_id = c.course_id 
WHERE e.student_id = 1; 
-- Q29. Calculate teaching load per professor (total credits taught) 
SELECT 
CONCAT(p.last_name, ' ', p.first_name) AS professor_name, 
SUM(c.credits) AS total_credits 
FROM professors p 
JOIN courses c ON p.professor_id = c.professor_id 
GROUP BY p.professor_id, p.last_name, p.first_name;

-- Q30. Identify overloaded courses (enrollments > 80% of max capacity)
SELECT c.course_name,
       COUNT(e.enrollment_id) AS current_enrollments,
       c.max_capacity,
       (COUNT(e.enrollment_id) * 100.0 / c.max_capacity) AS percentage_full 
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name, c.max_capacity
HAVING (COUNT(e.enrollment_id) * 100.0 / c.max_capacity) > 80;