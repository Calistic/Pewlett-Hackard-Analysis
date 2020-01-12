-- Creating tables for PH-EmployeeDB
CREATE TABLE employees (
     emp_no INT NOT NULL,
     birth_date DATE NOT NULL,
     first_name VARCHAR NOT NULL,
     last_name VARCHAR NOT NULL,
     gender VARCHAR NOT NULL,
     hire_date DATE NOT NULL,
     PRIMARY KEY (emp_no)
);

CREATE TABLE departments (
	dept_no VARCHAR(4) NOT NULL,
	dept_name VARCHAR(25) NOT NULL,
	PRIMARY KEY (dept_no)
);

CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no)
);

CREATE TABLE dept_emp (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR(25) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no)
);

SELECT * FROM employees;

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

-- Retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Create new table to save retirment info
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')

SELECT * FROM retirement_info;
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');


-- Create new table for retiring employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info;


-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no;


-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;


SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');




-- List of managers per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);
		
		
		
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);



-- PART 1
-- Number of [titles] Retiring
SELECT re.emp_no,
	re.first_name,
	re.last_name,
	ti.title,
	s.salary,
	s.from_date
INTO num_retire
FROM retirement_info AS re
INNER JOIN titles AS ti
ON (re.emp_no = ti.emp_no)
INNER JOIN salaries AS s
ON (ti.emp_no = s.emp_no);

-- Only the Most Recent Titles

-- Exclude the rows of data containing duplicate names.
SELECT num_retire.emp_no, 
	num_retire.first_name, 
	num_retire.last_name, 
	num_retire.from_date, 
	num_retire.title
INTO recent_titles
FROM
  (SELECT nr.emp_no, 
   		nr.first_name, 
   		nr.last_name, 
   		nr.from_date, 
   		nr.title,
     ROW_NUMBER() OVER 
	(PARTITION BY (nr.first_name, nr.last_name) 
	 ORDER BY nr.from_date DESC) rn
  FROM num_retire AS nr
  ) num_retire
WHERE rn = 1;

-- In descending order (by date), list the frequency count of employee titles
SELECT
  rt.title,
--   rt.from_date,
  count(*)
FROM recent_titles AS rt
GROUP BY
  title;
-- HAVING count(*) > 1;

-- Who’s Ready for a Mentor?

-----
-- PART 1
-- Number of [titles] Retiring
SELECT re.emp_no,
	re.first_name,
	re.last_name,
	ti.title,
	s.salary,
	s.from_date
INTO num_retire
FROM retirement_info AS re
INNER JOIN titles AS ti
ON (re.emp_no = ti.emp_no)
INNER JOIN salaries AS s
ON (ti.emp_no = s.emp_no);

-- Only the Most Recent Titles
-- -- Exclude the rows of data containing duplicate names.
SELECT num_retire.emp_no, 
	num_retire.first_name, 
	num_retire.last_name, 
	num_retire.from_date, 
	num_retire.title
-- INTO recent_titles
FROM
  (SELECT nr.emp_no, 
   		nr.first_name, 
   		nr.last_name, 
   		nr.from_date, 
   		nr.title,
     ROW_NUMBER() OVER 
	(PARTITION BY (nr.first_name, nr.last_name) 
	 ORDER BY nr.from_date DESC) rn
  FROM num_retire AS nr
  ) num_retire
WHERE rn = 1;

-- In descending order (by date), list the frequency count of employee titles
SELECT
  rt.title,
  count(*)
INTO num_title
FROM recent_titles AS rt
GROUP BY
  title;

-- Who’s Ready for a Mentor?
SELECT rt.emp_no,
	rt.first_name,
	rt.last_name,
	rt.title,
	rt.from_date,
	de.to_date,
	e.birth_date
-- INTO temp
FROM recent_titles AS rt
INNER JOIN dept_emp AS de
ON (rt.emp_no = de.emp_no)
INNER JOIN employees AS e
ON (de.emp_no = e.emp_no)
WHERE (e.birth_date BETWEEN '1955-01-01' AND '1965-12-31');