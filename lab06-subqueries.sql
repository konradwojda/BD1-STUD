ALTER SESSION SET nls_date_format = "DD/MM/YYYY";

SELECT SYSDATE
FROM DUAL;

--Æw 1

--Napisz zapytanie, które wyœwietli imiê, nazwisko oraz nazwy zak³adów, w których
--pracownicy maj¹ wiêksze zarobki ni¿ minimalne zarobki na stanowisku o nazwie
--˜?Konsultant’.

select e.employee_id, e.name, e.surname, e.salary, department_id, d.name dep_name
from employees e join departments d using (department_id)
where salary > (select min(e.salary)
from employees e join positions p using (position_id)
where p.name like 'Konsultant');

-- Napisz zapytanie, kt˜re zwr˜ci dane najm˜odszego w˜r˜d dzieci pracownik˜w. 

select d.name, d.surname
from dependents d
where d.birth_date = (select max(birth_date) from dependents);

select d.name, d.surname, birth_date
from dependents d
order by birth_date desc
fetch next 1 rows only;


--Wyœwietl œrednie zarobki dla ka¿dego ze stanowisk, o ile œrednie te s¹ wiêksze od
--œrednich zarobków w departamencie “Administracja”.

select position_id, p.name, round(avg(e.salary))
from employees e join positions p using (position_id)
where position_id is not null
group by position_id, p.name
having round(avg(e.salary)) > (select round(avg(e.salary)) from employees e join departments d using (department_id) where d.name like 'Administracja');


--Napisz zapytanie, kt˜re wy˜wietli wszystkich pracownik˜w, kt˜rzy zostali zatrudnieni 
--nie wcze˜niej ni˜ najwcze˜niej zatrudniony pracownik w zak˜adzie o id 101 i nie p˜niej 
--ni˜ najp˜niej zatrudniony pracownik w zak˜adzie o id 107.
select *
from employees e
where date_employed >= (select min(date_employed)
from employees
where department_id = 101) and date_employed <= (select min(date_employed)
from employees
where department_id = 107);


--Napisz zapytanie, które zwróci dane dzieci najstarszego pracownika z zak³adu 102.

select d.name, d.surname
from employees e join dependents d on (e.employee_id = d.employee_id)
where e.birth_date = (select MIN(birth_date)
from employees where department_id = '102');

select MIN(birth_date)
from employees
where department_id = '102';

--Æw 2

--Napisz zapytanie, które zwróci informacje o pracownikach zatrudnionych po
--zakoñczeniu wszystkich projektów (tabela projects). Zapytanie zrealizuj na 2 sposoby i
--porównaj wyniki

select *
from employees
where date_employed > (select max(date_end) from projects);

select *
from employees
where date_employed > ALL (select distinct date_end from projects where date_end is not null);

--Korzystaj¹c z podzapytañ napisz zapytanie które zwróci pracowników departamentów
--maj¹cych siedziby w Polsce.

select *
from employees
where department_id IN (select department_id
from departments d
join addresses a using (address_id)
join countries c using (country_id)
where c.name like 'Polska');

select department_id
from departments d
join addresses a using (address_id)
join countries c using (country_id)
where c.name like 'Polska';

--Zmodyfikuj poprzednie zapytania tak, ¿eby dodatkowo pokazaæ maksymaln¹ pensjê
--per departament.

select max(salary), department_id
from employees
where department_id IN (select department_id
from departments d
join addresses a using (address_id)
join countries c using (country_id)
where c.name like 'Polska')
group by department_id;

--Napisz zapytanie, kt˜re wy˜wietli wszystkich pracownik˜w, kt˜rych zarobki s˜ co 
--najmniej czterokrotnie wi˜ksze od zarobk˜w jakiegokolwiek innego pracownika.

select *
from employees
where salary >= ANY (select 4*salary from employees); 


-- Æw 3

--Napisz zapytanie, które zwróci pracowników zarabiaj¹cych wiêcej ni¿ œrednia w ich
--departamencie.

select *
from employees e1
where salary > (
    select avg(salary)
    from employees e2 
    where (e1.department_id = e2.department_id));

--Za pomoc¹ podzapytania skorelowanego sprawdŸ, czy wszystkie stanowiska
--zdefiniowane w tabeli Positions s¹ aktualnie zajête przez pracowników.

select count(*)
from positions p
where NOT EXISTS (select * from employees e where (e.position_id = p.position_id));

-- Napisz zapytanie kt˜re zwr˜ci regiony nieprzypisane do kraj˜w
select *
from regions r
where NOT EXISTS (select * from reg_countries rc where rc.region_id = r.region_id);

-- Napisz zapytanie kt˜re zwr˜ci kraje nieprzypisane do region˜w
select *
from countries c
where NOT EXISTS (select * from reg_countries rc where rc.country_id = c.country_id);

--Napisz zapytanie, kt˜re zwr˜ci wszystkich pracownik˜w nieb˜d˜cych managerami.
select *
from employees e1
where NOT EXISTS (select * from employees e2 where e1.employee_id = e2.manager_id);

--Napisz zapytanie, kt˜re zwr˜ci dane pracownik˜w, kt˜rzy zarabiaj˜ wi˜cej ni˜ ˜rednie 
--zarobki na stanowisku, na kt˜rym pracuj˜
select *
from employees e
where salary > (select avg(salary) from employees e2 where e2.position_id = e.position_id);

-- Æw 4

--Napisz zapytanie, które dla wszystkich pracowników posiadaj¹cych pensjê
--zwróci informacjê o ró¿nicy miêdzy ich pensj¹, a œredni¹ pensj¹ pracowników.
--Ró¿nicê podaj jako zaokr¹glon¹ wartoœæ bezwzglêdn¹.


select name, surname, ABS(ROUND(salary - (select avg(salary) from employees))) as avg_all_diff_abs
from employees
where salary is not null;

-- Korzystaj˜c z poprzedniego rozwi˜zania, napisz zapytanie, kt˜re zwr˜ci tylko 
--tych pracownik˜w, kt˜rzy s˜ kobietami i dla kt˜rych r˜nica do warto˜ci 
--˜redniej jest powy˜ej 1000.
select name, surname, ABS(ROUND(salary - (select avg(salary) from employees))) as avg_all_diff_abs
from employees
where salary is not null and gender like 'K' and ABS(ROUND(salary - (select avg(salary) from employees))) > 1000;


--Zmodyfikuj poprzednie zapytanie tak aby obliczy˜ liczbe pracownik˜w. 
--(skorzystaj z podzapytania)

select count(*) from (select name, surname, ABS(ROUND(salary - (select avg(salary) from employees))) as avg_all_diff_abs
from employees
where salary is not null and gender like 'K' and ABS(ROUND(salary - (select avg(salary) from employees))) > 1000);

--Napisz zapytanie kt˜re zwr˜ci informacje o pracownikach zatrudnionych po 
--zako˜czeniu wszystkich projekt˜w (tabela projects). W wynikach zapytania umie˜˜ jako 
--kolumn˜ dat˜ graniczn˜.

select name, surname, date_employed, (select max(date_end) from projects)
from employees
where date_employed > (select max(date_end) from projects);

-- Napisz zapytanie kt˜re zwr˜ci pracownik˜w kt˜rzy uzyskali w 2019 oceny wy˜sze ni˜ 
--˜rednia w swoim departamencie. Poka˜ ˜redni˜ departamentu jako kolumn˜. 
select e1.name, e1.surname, g.grade, 
(select avg(g.grade)
from employees e2
join emp_grades eg on (e2.employee_id = eg.employee_id)
join grades g on (eg.grade_id = g.grade_id)
where eg.period = 2019 and (e1.department_id = e2.department_id)) as avg

from employees e1
join emp_grades eg on (e1.employee_id = eg.employee_id)
join grades g on (eg.grade_id = g.grade_id)
where eg.period = 2019 and g.grade >
(
select avg(g.grade)
from employees e2
join emp_grades eg on (e2.employee_id = eg.employee_id)
join grades g on (eg.grade_id = g.grade_id)
where eg.period = 2019 and (e1.department_id = e2.department_id)
);

-- Praca domowa

-- Skonstruuj po jednym zapytaniu, kt˜re b˜dzie zawiera˜ w klauzuli WHERE:
--a. podzapytanie zwracaj˜ce tylko jedn˜ warto˜˜;
--b. podzapytanie zwracaj˜ce jeden wiersz danych, ale wiele kolumn;
--c. podzapytanie zwracaj˜ce jedn˜ kolumn˜ danych;
--d. podzapytanie zwracaj˜ce tabel˜ danych.

--a.

select *
from employees
where salary > (select avg(salary) from employees);

--b.
select * 
from employees
where (salary, gender) = (select min(salary), 'M' from employees where gender like 'M');

--c.
select *
from employees
where salary >= any (select salary from employees);

--d.
select *
from employees
where (name, gender) in (SELECT name, gender FROM employees ORDER BY salary FETCH NEXT 5 ROWS ONLY);

--Napisz zapytanie, kt˜re zwr˜ci pracownik˜w b˜d˜cych kierownikami zak˜ad˜w, o ile ich 
--zarobki s˜ wi˜ksze ni˜ ˜rednia zarobk˜w dla wszystkich pracownik˜w
select *
from employees e1
where exists (select * from departments d where d.manager_id = e1.employee_id)
and e1.salary > (select avg(salary) from employees);

-- Zmodyfikuj powy˜sze zapytanie tak, aby wy˜wietla˜o wszystkich pracownik˜w 
--b˜d˜cych kierownikami zak˜ad˜w, o ile ich zarobki s˜ wi˜ksze ni˜ ˜rednia zarobk˜w na 
--stanowisku kt˜re zajmuj˜.
select *
from employees e1
where exists (select * from departments d where d.manager_id = e1.employee_id)
and e1.salary > (select avg(salary) from employees e2 where e1.position_id = e2.position_id);

--. W kt˜rych klauzulach polecenia SELECT mo˜emy wykorzysta˜ podzapytania 
--nieskorelowane?
-- where, from, having, select

--. W kt˜rych klauzulach polecenia SELECT mo˜emy wykorzysta˜ podzapytania skorelowane?
-- where, having, select



