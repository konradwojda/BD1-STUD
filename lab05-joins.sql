ALTER SESSION SET nls_date_format = "DD/MM/YYYY";

SELECT SYSDATE
FROM DUAL;

--Poka� wszystkie kombinacje pracownik�w (employees) oraz uzyskanych
--ocen z oceny rocznej (grades). Poka� identyfikator pracownika oraz ocen�
--liczbow� i jej opis.
--Zmodyfikuj poprzednie zapytanie tak aby pokaza� tylko pracownik�w z
--departament�w 101, 102, 103 lub bez departamentu.

select e.employee_id, g.grade, g.description
from employees e cross join grades g
where e.department_id in (101, 102, 103) or e.department_id is null;

--Znajd� pracownik�w, kt�rych zarobki nie s� zgodne z �wide�kami� na jego
--stanowisku. Zwr�� imi�, nazwisko, wynagrodzenie oraz nazw� stanowiska

--Zmodyfikuj poprzednie zapytanie tak, aby dodatkowo wy�wietli� informacje
--o nazwie zak�adu pracownika.

select e.name, e.surname, e.salary, d.name, p.name
from employees e join positions p  using (position_id) join departments d using(department_id)
where e.salary not between p.min_salary and p.max_salary;

--Wy�wietl nazw� zak�adu wraz z imieniem i nazwiskiem jego kierownik�w.
--Poka� tylko zak�ady, kt�re maj� bud�et pomi�dzy 5000000 i 10000000.

select d.name, e.name, e.surname
from departments d join employees e on (d.manager_id = e.employee_id)
where d.year_budget between 5000000 and 10000000;

--Znajd� zak�ady (podaj ich nazw�), kt�re maj� swoje siedziby w Polsce.
select d.name
from departments d
join addresses a using (address_id)
join countries c using (country_id)
where c.name like 'Polska';

-- Zmodyfikuj zapytanie 3 tak, aby uwzgl�dnia� w wynikach tylko zak�ady,
--kt�re maj� siedziby w Polsce.
select d.name, e.name, e.surname
from departments d 
join employees e on (d.manager_id = e.employee_id)
join addresses a using (address_id)
join countries c using (country_id)
where d.year_budget between 5000000 and 10000000
and c.name like 'Polska';

-- Poka� oceny (grades) pracownik�w kt�rzy nie posiadaj� kierownika. W
--wynikach poka� imie , nazwisko pracownika, ocene liczbowa i jej opis.

select e.name, e.surname, g.grade, g.description
from employees e
join emp_grades using (employee_id)
join grades g using (grade_id)
where e.manager_id is NULL;

--Poka� nazw� kraju i nazw� regionu do kt�rego zosta� przypisany.
select * from reg_countries rc natural join regions r join countries c on (c.country_id = rc.country_id);

--Wy�wietl list� zawieraj�c� nazwisko pracownika, stanowisko, na kt�rym
--pracuje, aktualne zarobki oraz wide�ki p�acowe dla tego stanowiska.
--Steruj�c rodzajem z��czenia, zagwarantuj, �e w wynikach znajd� si�
--wszyscy pracownicy

select e.surname, p.name, e.salary, p.max_salary, p.min_salary
from employees e
left join positions p using (position_id);


--Wy�wietl �redni� pensj� oraz liczb� os�b zatrudnionych dla stanowisk.
--Steruj�c rodzajem z��czenia zagwarantuj, �e znajd� si� tam r�wnie�
--stanowiska, na kt�rych nikt nie jest zatrudniony

select avg(e.salary), count(e.employee_id) from positions p left outer join employees e on (e.position_id = p.position_id) group by p.position_id;

--Poka� liczb� pracownik�w zatrudnionych kiedykolwiek w ka�dym projekcie.
--Zadbaj by w wynikach pojawi� si� ka�dy projekt.

select count(employee_id), p.name
from employees e
join emp_projects using (employee_id)
right join projects p using (project_id)
group by project_id, p.name;

-- Poka� �redni� ocen� pracownik�w per departament. W wynikach zamiesc
--nazwe departamentu i srednia ocene.

select avg(g.grade), d.name
from grades g
join emp_grades using (grade_id)
join employees e using (employee_id)
right join departments d using (department_id)
group by department_id, d.name;

--Dla ka�dego imienia pracownika z zak�ad�w Administracja lub Marketing zwr��
--liczb� pracownik�w, kt�rzy maj� takie samo imi� i podaj ich �rednie zarobki

select e.name, count(e.name), avg(e.salary)
from employees e
join departments d using (department_id)
where d.name in ('Administracja', 'Marketing')
group by e.name;

--Zwr�� imiona i nazwiska pracownik�w, kt�rzy przeszli wi�cej ni� 2 zmiany
--stanowiska. Wyniki posortuj malej�co wg liczby zmian.

select e.name, e.surname, count(*) changes
from employees e
join positions_history using (employee_id)
group by (employee_id, e.name, e.surname)
having count(*) > 2
order by changes desc;

--Zwr�� id, nazwisko kierownik�w oraz liczb� podleg�ych pracownik�w. Wyniki
--posortuj malej�co wg liczby podleg�ych pracownik�w. 

select m.employee_id, m.name, m.surname, count(*)
from employees e
join employees m on (m.employee_id = e.manager_id)
group by (m.employee_id, m.name, m.surname)
order by count(*) desc;


-- Napisz zapytanie zwracaj�ce liczb� zak�ad�w w krajach. W wynikach podaj
--nazw� kraju oraz jego ludno��.

select c.name, c.population, count(*)
from departments d
join addresses a using (address_id)
right join countries c using (country_id)
group by country_id, c.name, c.population;


--. Napisz zapytanie zwracaj�ce liczb� zak�ad�w w regionach. W wynikach podaj
--nazw� regionu. Wynik posortuj malej�co wzgl�dem liczby zak�ad�w.

select r.region_id, count(d.department_id) from regions r 
left outer join reg_countries rc on (r.region_id = rc.region_id)
left outer join addresses a on (rc.country_id = a.country_id)
join departments d on (d.address_id = a.address_id)
group by r.region_id order by count(d.department_id) desc;


-- PRACA DOMOWA

-- Napisz zapytanie znajduj�ce liczb� zmian stanowisk pracownika Jan Kowalski.

select count(*) changes
from employees e
join positions_history using (employee_id)
where e.name like 'Jan' and e.surname like 'Kowalski';

--Napisz zapytanie znajduj�ce �redni� pensj� dla ka�dego ze stanowisk. Wynik
--powinien zawiera� nazw� stanowiska i zaokr�glon� �redni� pensj�.

select p.name, ROUND(avg(salary))
from positions p
join employees e using (position_id)
group by p.name, position_id;

-- Pobierz wszystkich pracownik�w zak�adu Kadry lub Finanse wraz z informacj� w
--jakim zak�adzie pracuj�

select e.name, e.surname, d.name
from employees e
join departments d using (department_id)
where d.name in ('Kadry', 'Finanse');

--Znajd� pracownik�w, kt�rych zarobki nie s� zgodne z �wide�kami� na jego
--stanowisku. Zwr�� imi�, nazwisko, wynagrodzenie oraz nazw� stanowiska.
--Zrealizuj za pomoc� z��czenia nier�wno�ciowego.

select e.name, e.surname, e.salary, p.name
from employees e 
left join positions p using (position_id)
where e.salary not between p.min_salary and p.max_salary;

--Poka� nazwy region�w w kt�rych nie ma �adnego kraju.

select r.name
from regions r 
left join reg_countries rc using (region_id)
where rc.country_id is null;

-- Wykonaj z��czenie naturalne mi�dzy tabelami countries a regions. Jaki wynik
--otrzymujemy i dlaczego?
select *
from countries natural join regions;

-- Otrzymujemy pust� tabel�, poniewa� ��czymy tabele po wsp�lnej nazwie - name
-- nie ma regionu o takiej samej nazwie jak kraj

--Jaki otrzymamy wynik je�li zrobimy NATURAL JOIN na tabelach bez wsp�lnej
--kolumny? Sprawd� i zastan�w si� nad przyczyn�

select *
from positions natural join grades;

-- wykona� si� cross join, poniewa� nie ma wsp�lnej kolumny





