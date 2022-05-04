ALTER SESSION SET nls_date_format = "DD/MM/YYYY";

SELECT SYSDATE
FROM DUAL;

-- Æwiczenia - grupowanie

select status_id, count(*)
from employees
where gender like 'K'
group by status_id;

select position_id, min(salary), max(salary), avg(salary), median(salary), stddev(salary)
from employees
group by position_id;

select language, count(*), avg(population)
from countries
group by language;

select gender, avg(salary) avg_salary, avg(floor(months_between(sysdate, date_employed)/12)) avg_years_employed
from employees
group by gender
order by avg_salary desc;

select extract(year from established), count(department_id)
from departments 
group by extract(year from established);

select extract(month from date_employed), count(*)
from employees
group by extract(month from date_employed)
order by extract(month from date_employed) asc;

-- Æwiczenia - HAVING

select language, count(*) 
from countries 
group by language 
having count(*) >= 2;

select position_id, avg(salary)
from employees
group by position_id
having avg(salary) > 2000;

select position_id, avg(salary), count(*)
from employees
group by position_id
having avg(salary) > 2000 and count(*) > 1;

SELECT AVG(salary), department_id, status_id
FROM employees
WHERE status_id IN (301, 304)
GROUP BY department_id, status_id;

SELECT AVG(salary), department_id, status_id
FROM employees
GROUP BY department_id, status_id
HAVING status_id IN (301, 304);

-- Æwiczenia - operatory UNION (ALL), INTERSECT, MINUS?

select name, shortname, 'R'
from regions
union
select name, code, 'K'
from countries;
--order by 3;

select name, surname, 'P'
from employees
union
select name, surname, 'D'
from dependents;

select employee_id, name, surname
from employees
where department_id = 101
union
select employee_id, name, surname
from employees
where department_id = 103;

select name
from positions
where name like 'P%' or name like 'K%' or name LIKE 'A%'
INTERSECT
select name
from positions
where min_salary >= 1500;

select avg(salary), position_id
from employees
group by position_id
minus
select avg(salary), position_id
from employees
group by position_id
having position_id = 102
order by 1 desc;

-- Praca domowa

select avg(salary), department_id, count(*)
from employees
where date_employed < '01-01-2020'
group by department_id
having count(*) > 2;


select avg(salary), department_id
from employees
where date_employed < '01-01-2020'
group by department_id
MINUS
select avg(salary), department_id
from employees 
group by department_id 
having count(*) < 3;


select avg(salary), department_id, gender
from employees
group by department_id, gender
order by 2 asc;

select count(*), SUBSTR(language, 0, 1)
from countries
group by SUBSTR(language, 0, 1);

-- SELECT name, surname, COUNT(*) FROM employees GROUP BY name HAVING COUNT(*) >=2
-- Osoby o tym samym imieniu moga, i zazwyczaj maja, ró¿ne nazwiska wiêc po pogrupowaniu nie jesteœmy w stanie wybrac nazwiska.

select MAX(salary), department_id
from employees
group by department_id;

select count(count(*))
from countries
group by currency
having count(*) > 1;

select AVG(count)
from (select position_id, COUNT(*) count FROM positions_history GROUP BY position_id);

-- Przy grupowaniu danych wykorzystuj¹c jedn¹ kolumnê, ile powstanie grup danych?
-- Tyle ile unikalnych wierszy w danej kolumnie.














