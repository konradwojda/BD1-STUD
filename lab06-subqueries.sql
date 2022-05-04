ALTER SESSION SET nls_date_format = "DD/MM/YYYY";

SELECT SYSDATE
FROM DUAL;

--Ä†w 1

--Napisz zapytanie, ktÃ³re wyÅ›wietli imiÄ™, nazwisko oraz nazwy zakÅ‚adÃ³w, w ktÃ³rych
--pracownicy majÄ… wiÄ™ksze zarobki niÅ¼ minimalne zarobki na stanowisku o nazwie
--â€?Konsultantâ€™.

select e.employee_id, e.name, e.surname, e.salary, department_id, d.name dep_name
from employees e join departments d using (department_id)
where salary > (select min(e.salary)
from employees e join positions p using (position_id)
where p.name like 'Konsultant');

-- Napisz zapytanie, które zwróci dane najm³odszego wœród dzieci pracowników. 

select d.name, d.surname
from dependents d
where d.birth_date = (select max(birth_date) from dependents);

select d.name, d.surname, birth_date
from dependents d
order by birth_date desc
fetch next 1 rows only;


--WyÅ›wietl Å›rednie zarobki dla kaÅ¼dego ze stanowisk, o ile Å›rednie te sÄ… wiÄ™ksze od
--Å›rednich zarobkÃ³w w departamencie â€œAdministracjaâ€.

select position_id, p.name, round(avg(e.salary))
from employees e join positions p using (position_id)
where position_id is not null
group by position_id, p.name
having round(avg(e.salary)) > (select round(avg(e.salary)) from employees e join departments d using (department_id) where d.name like 'Administracja');


--Napisz zapytanie, które wyœwietli wszystkich pracowników, którzy zostali zatrudnieni 
--nie wczeœniej ni¿ najwczeœniej zatrudniony pracownik w zak³adzie o id 101 i nie póŸniej 
--ni¿ najpóŸniej zatrudniony pracownik w zak³adzie o id 107.
select *
from employees e
where date_employed >= (select min(date_employed)
from employees
where department_id = 101) and date_employed <= (select min(date_employed)
from employees
where department_id = 107);


--Napisz zapytanie, ktÃ³re zwrÃ³ci dane dzieci najstarszego pracownika z zakÅ‚adu 102.

select d.name, d.surname
from employees e join dependents d on (e.employee_id = d.employee_id)
where e.birth_date = (select MIN(birth_date)
from employees where department_id = '102');

select MIN(birth_date)
from employees
where department_id = '102';

--Ä†w 2

--Napisz zapytanie, ktÃ³re zwrÃ³ci informacje o pracownikach zatrudnionych po
--zakoÅ„czeniu wszystkich projektÃ³w (tabela projects). Zapytanie zrealizuj na 2 sposoby i
--porÃ³wnaj wyniki

select *
from employees
where date_employed > (select max(date_end) from projects);

select *
from employees
where date_employed > ALL (select distinct date_end from projects where date_end is not null);

--KorzystajÄ…c z podzapytaÅ„ napisz zapytanie ktÃ³re zwrÃ³ci pracownikÃ³w departamentÃ³w
--majÄ…cych siedziby w Polsce.

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

--Zmodyfikuj poprzednie zapytania tak, Å¼eby dodatkowo pokazaÄ‡ maksymalnÄ… pensjÄ™
--per departament.

select max(salary), department_id
from employees
where department_id IN (select department_id
from departments d
join addresses a using (address_id)
join countries c using (country_id)
where c.name like 'Polska')
group by department_id;

--Napisz zapytanie, które wyœwietli wszystkich pracowników, których zarobki s¹ co 
--najmniej czterokrotnie wiêksze od zarobków jakiegokolwiek innego pracownika.

select *
from employees
where salary >= ANY (select 4*salary from employees); 


-- Ä†w 3

--Napisz zapytanie, ktÃ³re zwrÃ³ci pracownikÃ³w zarabiajÄ…cych wiÄ™cej niÅ¼ Å›rednia w ich
--departamencie.

select *
from employees e1
where salary > (
    select avg(salary)
    from employees e2 
    where (e1.department_id = e2.department_id));

--Za pomocÄ… podzapytania skorelowanego sprawdÅº, czy wszystkie stanowiska
--zdefiniowane w tabeli Positions sÄ… aktualnie zajÄ™te przez pracownikÃ³w.

select count(*)
from positions p
where NOT EXISTS (select * from employees e where (e.position_id = p.position_id));

-- Napisz zapytanie które zwróci regiony nieprzypisane do krajów
select *
from regions r
where NOT EXISTS (select * from reg_countries rc where rc.region_id = r.region_id);

-- Napisz zapytanie które zwróci kraje nieprzypisane do regionów
select *
from countries c
where NOT EXISTS (select * from reg_countries rc where rc.country_id = c.country_id);

--Napisz zapytanie, które zwróci wszystkich pracowników niebêd¹cych managerami.
select *
from employees e1
where NOT EXISTS (select * from employees e2 where e1.employee_id = e2.manager_id);

--Napisz zapytanie, które zwróci dane pracowników, którzy zarabiaj¹ wiêcej ni¿ œrednie 
--zarobki na stanowisku, na którym pracuj¹
select *
from employees e
where salary > (select avg(salary) from employees e2 where e2.position_id = e.position_id);

-- Ä†w 4

--Napisz zapytanie, ktÃ³re dla wszystkich pracownikÃ³w posiadajÄ…cych pensjÄ™
--zwrÃ³ci informacjÄ™ o rÃ³Å¼nicy miÄ™dzy ich pensjÄ…, a Å›redniÄ… pensjÄ… pracownikÃ³w.
--RÃ³Å¼nicÄ™ podaj jako zaokrÄ…glonÄ… wartoÅ›Ä‡ bezwzglÄ™dnÄ….


select name, surname, ABS(ROUND(salary - (select avg(salary) from employees))) as avg_all_diff_abs
from employees
where salary is not null;

-- Korzystaj¹c z poprzedniego rozwi¹zania, napisz zapytanie, które zwróci tylko 
--tych pracowników, którzy s¹ kobietami i dla których ró¿nica do wartoœci 
--œredniej jest powy¿ej 1000.
select name, surname, ABS(ROUND(salary - (select avg(salary) from employees))) as avg_all_diff_abs
from employees
where salary is not null and gender like 'K' and ABS(ROUND(salary - (select avg(salary) from employees))) > 1000;


--Zmodyfikuj poprzednie zapytanie tak aby obliczyæ liczbe pracowników. 
--(skorzystaj z podzapytania)

select count(*) from (select name, surname, ABS(ROUND(salary - (select avg(salary) from employees))) as avg_all_diff_abs
from employees
where salary is not null and gender like 'K' and ABS(ROUND(salary - (select avg(salary) from employees))) > 1000);

--Napisz zapytanie które zwróci informacje o pracownikach zatrudnionych po 
--zakoñczeniu wszystkich projektów (tabela projects). W wynikach zapytania umieœæ jako 
--kolumnê datê graniczn¹.

select name, surname, date_employed, (select max(date_end) from projects)
from employees
where date_employed > (select max(date_end) from projects);

-- Napisz zapytanie które zwróci pracowników którzy uzyskali w 2019 oceny wy¿sze ni¿ 
--œrednia w swoim departamencie. Poka¿ œredni¹ departamentu jako kolumnê. 
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

-- Skonstruuj po jednym zapytaniu, które bêdzie zawieraæ w klauzuli WHERE:
--a. podzapytanie zwracaj¹ce tylko jedn¹ wartoœæ;
--b. podzapytanie zwracaj¹ce jeden wiersz danych, ale wiele kolumn;
--c. podzapytanie zwracaj¹ce jedn¹ kolumnê danych;
--d. podzapytanie zwracaj¹ce tabelê danych.

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

--Napisz zapytanie, które zwróci pracowników bêd¹cych kierownikami zak³adów, o ile ich 
--zarobki s¹ wiêksze ni¿ œrednia zarobków dla wszystkich pracowników
select *
from employees e1
where exists (select * from departments d where d.manager_id = e1.employee_id)
and e1.salary > (select avg(salary) from employees);

-- Zmodyfikuj powy¿sze zapytanie tak, aby wyœwietla³o wszystkich pracowników 
--bêd¹cych kierownikami zak³adów, o ile ich zarobki s¹ wiêksze ni¿ œrednia zarobków na 
--stanowisku które zajmuj¹.
select *
from employees e1
where exists (select * from departments d where d.manager_id = e1.employee_id)
and e1.salary > (select avg(salary) from employees e2 where e1.position_id = e2.position_id);

--. W których klauzulach polecenia SELECT mo¿emy wykorzystaæ podzapytania 
--nieskorelowane?
-- where, from, having, select

--. W których klauzulach polecenia SELECT mo¿emy wykorzystaæ podzapytania skorelowane?
-- where, having, select



