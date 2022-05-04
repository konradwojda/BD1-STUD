ALTER SESSION SET nls_date_format = "DD/MM/YYYY";

SELECT SYSDATE
FROM DUAL;

--Pokaż wszystkie kombinacje pracowników (employees) oraz uzyskanych
--ocen z oceny rocznej (grades). Pokaż identyfikator pracownika oraz ocenę
--liczbową i jej opis.
--Zmodyfikuj poprzednie zapytanie tak aby pokazać tylko pracowników z
--departamentów 101, 102, 103 lub bez departamentu.

select e.employee_id, g.grade, g.description
from employees e cross join grades g
where e.department_id in (101, 102, 103) or e.department_id is null;

--Znajdź pracowników, których zarobki nie są zgodne z “widełkami” na jego
--stanowisku. Zwróć imię, nazwisko, wynagrodzenie oraz nazwę stanowiska

--Zmodyfikuj poprzednie zapytanie tak, aby dodatkowo wyświetlić informacje
--o nazwie zakładu pracownika.

select e.name, e.surname, e.salary, d.name, p.name
from employees e join positions p  using (position_id) join departments d using(department_id)
where e.salary not between p.min_salary and p.max_salary;

--Wyświetl nazwę zakładu wraz z imieniem i nazwiskiem jego kierowników.
--Pokaż tylko zakłady, które mają budżet pomiędzy 5000000 i 10000000.

select d.name, e.name, e.surname
from departments d join employees e on (d.manager_id = e.employee_id)
where d.year_budget between 5000000 and 10000000;

--Znajdź zakłady (podaj ich nazwę), które mają swoje siedziby w Polsce.
select d.name
from departments d
join addresses a using (address_id)
join countries c using (country_id)
where c.name like 'Polska';

-- Zmodyfikuj zapytanie 3 tak, aby uwzględniać w wynikach tylko zakłady,
--które mają siedziby w Polsce.
select d.name, e.name, e.surname
from departments d 
join employees e on (d.manager_id = e.employee_id)
join addresses a using (address_id)
join countries c using (country_id)
where d.year_budget between 5000000 and 10000000
and c.name like 'Polska';

-- Pokaż oceny (grades) pracowników którzy nie posiadają kierownika. W
--wynikach pokaż imie , nazwisko pracownika, ocene liczbowa i jej opis.

select e.name, e.surname, g.grade, g.description
from employees e
join emp_grades using (employee_id)
join grades g using (grade_id)
where e.manager_id is NULL;

--Pokaż nazwę kraju i nazwę regionu do którego został przypisany.
select * from reg_countries rc natural join regions r join countries c on (c.country_id = rc.country_id);

--Wyświetl listę zawierającą nazwisko pracownika, stanowisko, na którym
--pracuje, aktualne zarobki oraz widełki płacowe dla tego stanowiska.
--Sterując rodzajem złączenia, zagwarantuj, że w wynikach znajdą się
--wszyscy pracownicy

select e.surname, p.name, e.salary, p.max_salary, p.min_salary
from employees e
left join positions p using (position_id);


--Wyświetl średnią pensję oraz liczbę osób zatrudnionych dla stanowisk.
--Sterując rodzajem złączenia zagwarantuj, że znajdą się tam również
--stanowiska, na których nikt nie jest zatrudniony

select avg(e.salary), count(e.employee_id) from positions p left outer join employees e on (e.position_id = p.position_id) group by p.position_id;

--Pokaż liczbę pracowników zatrudnionych kiedykolwiek w każdym projekcie.
--Zadbaj by w wynikach pojawił się każdy projekt.

select count(employee_id), p.name
from employees e
join emp_projects using (employee_id)
right join projects p using (project_id)
group by project_id, p.name;

-- Pokaż średnią ocenę pracowników per departament. W wynikach zamiesc
--nazwe departamentu i srednia ocene.

select avg(g.grade), d.name
from grades g
join emp_grades using (grade_id)
join employees e using (employee_id)
right join departments d using (department_id)
group by department_id, d.name;

--Dla każdego imienia pracownika z zakładów Administracja lub Marketing zwróć
--liczbę pracowników, którzy mają takie samo imię i podaj ich średnie zarobki

select e.name, count(e.name), avg(e.salary)
from employees e
join departments d using (department_id)
where d.name in ('Administracja', 'Marketing')
group by e.name;

--Zwróć imiona i nazwiska pracowników, którzy przeszli więcej niż 2 zmiany
--stanowiska. Wyniki posortuj malejąco wg liczby zmian.

select e.name, e.surname, count(*) changes
from employees e
join positions_history using (employee_id)
group by (employee_id, e.name, e.surname)
having count(*) > 2
order by changes desc;

--Zwróć id, nazwisko kierowników oraz liczbę podległych pracowników. Wyniki
--posortuj malejąco wg liczby podległych pracowników. 

select m.employee_id, m.name, m.surname, count(*)
from employees e
join employees m on (m.employee_id = e.manager_id)
group by (m.employee_id, m.name, m.surname)
order by count(*) desc;


-- Napisz zapytanie zwracające liczbę zakładów w krajach. W wynikach podaj
--nazwę kraju oraz jego ludność.

select c.name, c.population, count(*)
from departments d
join addresses a using (address_id)
right join countries c using (country_id)
group by country_id, c.name, c.population;


--. Napisz zapytanie zwracające liczbę zakładów w regionach. W wynikach podaj
--nazwę regionu. Wynik posortuj malejąco względem liczby zakładów.

select r.region_id, count(d.department_id) from regions r 
left outer join reg_countries rc on (r.region_id = rc.region_id)
left outer join addresses a on (rc.country_id = a.country_id)
join departments d on (d.address_id = a.address_id)
group by r.region_id order by count(d.department_id) desc;


-- PRACA DOMOWA

-- Napisz zapytanie znajdujące liczbę zmian stanowisk pracownika Jan Kowalski.

select count(*) changes
from employees e
join positions_history using (employee_id)
where e.name like 'Jan' and e.surname like 'Kowalski';

--Napisz zapytanie znajdujące średnią pensję dla każdego ze stanowisk. Wynik
--powinien zawierać nazwę stanowiska i zaokrągloną średnią pensję.

select p.name, ROUND(avg(salary))
from positions p
join employees e using (position_id)
group by p.name, position_id;

-- Pobierz wszystkich pracowników zakładu Kadry lub Finanse wraz z informacją w
--jakim zakładzie pracują

select e.name, e.surname, d.name
from employees e
join departments d using (department_id)
where d.name in ('Kadry', 'Finanse');

--Znajdź pracowników, których zarobki nie są zgodne z “widełkami” na jego
--stanowisku. Zwróć imię, nazwisko, wynagrodzenie oraz nazwę stanowiska.
--Zrealizuj za pomocą złączenia nierównościowego.

select e.name, e.surname, e.salary, p.name
from employees e 
left join positions p using (position_id)
where e.salary not between p.min_salary and p.max_salary;

--Pokaż nazwy regionów w których nie ma żadnego kraju.

select r.name
from regions r 
left join reg_countries rc using (region_id)
where rc.country_id is null;

-- Wykonaj złączenie naturalne między tabelami countries a regions. Jaki wynik
--otrzymujemy i dlaczego?
select *
from countries natural join regions;

-- Otrzymujemy pustą tabelę, ponieważ łączymy tabele po wspólnej nazwie - name
-- nie ma regionu o takiej samej nazwie jak kraj

--Jaki otrzymamy wynik jeśli zrobimy NATURAL JOIN na tabelach bez wspólnej
--kolumny? Sprawdź i zastanów się nad przyczyną

select *
from positions natural join grades;

-- wykonał się cross join, ponieważ nie ma wspólnej kolumny





