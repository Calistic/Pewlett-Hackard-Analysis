-- Notes
-- -- Tables were created in the module lesson. See file: queries.sql

-- CHALLENGE  CHALLENGE  CHALLENGE  CHALLENGE  CHALLENGE 

-- PART 1a -- PART 1a -- PART 1a -- PART 1a -- PART 1a --
-- -- Number of [titles] Retiring
-- -- Create list of retirement age employees
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	ti.title,
	s.salary,
	s.from_date
INTO retire_list
FROM retirement_info AS ri
INNER JOIN titles AS ti
ON (ri.emp_no = ti.emp_no)
INNER JOIN salaries AS s
ON (ti.emp_no = s.emp_no);

-- PART 1b -- PART 1b -- PART 1b -- PART 1b -- PART 1b --
-- -- Exclude the rows of data containing duplicate names. 
-- -- Only keep the most recent titles.
SELECT retire_list.emp_no, 
	retire_list.first_name, 
	retire_list.last_name, 
	retire_list.from_date, 
	retire_list.title
INTO retire_list_filtered
FROM
  (SELECT rl.emp_no, 
   		rl.first_name, 
   		rl.last_name, 
   		rl.from_date, 
   		rl.title,
     ROW_NUMBER() OVER 
	(PARTITION BY (rl.first_name, rl.last_name) 
	 ORDER BY rl.from_date DESC) rn
  FROM retire_list AS rl
  ) retire_list
WHERE rn = 1;

-- List the frequency count of employee titles
SELECT
  rlf.title,
  count(*)
INTO retire_list_count
FROM retire_list_filtered AS rlf
GROUP BY
  title;

-- PART 1c -- PART 1c -- PART 1c -- PART 1c -- PART 1c --
-- -- Get list of everyone with required information
CREATE VIEW mentor_long_list AS
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.birth_date,
	ti.title,
	s.salary,
	s.from_date
FROM employees AS e
INNER JOIN titles AS ti
ON (e.emp_no = ti.emp_no)
INNER JOIN salaries AS s
ON (ti.emp_no = s.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31');

-- -- Exclude the rows of data containing duplicate names.
CREATE VIEW mentor_short_list AS
SELECT mentor_long_list.emp_no, 
	mentor_long_list.first_name, 
	mentor_long_list.last_name, 
	mentor_long_list.from_date, 
	mentor_long_list.title
FROM
  (SELECT mll.emp_no, 
   		mll.first_name, 
   		mll.last_name, 
   		mll.from_date, 
   		mll.title,
     ROW_NUMBER() OVER 
	(PARTITION BY (mll.first_name, mll.last_name) 
	 ORDER BY mll.from_date DESC) rn
  FROM mentor_long_list AS mll
  ) mentor_long_list
WHERE rn = 1;

-- -- Filter for currently employed
CREATE TABLE mentor_list AS
SELECT msl.emp_no,
	msl.first_name,
	msl.last_name,
	msl.title,
	msl.from_date,
	de.to_date
FROM mentor_short_list AS msl
INNER JOIN dept_emp AS de
ON (msl.emp_no = de.emp_no)
WHERE (to_date = '9999-01-01');

-- Count mentor list
SELECT COUNT(*)
FROM mentor_list;

-- Count retire_list_filtered
SELECT COUNT(*)
FROM retire_list_filtered;