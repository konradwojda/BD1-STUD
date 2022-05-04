ALTER SESSION SET nls_date_format = "DD/MM/YYYY";

SELECT SYSDATE
FROM DUAL;

--Poka¿ wszystkie kombinacje pracowników (employees) oraz uzyskanych
--ocen z oceny rocznej (grades). Poka¿ identyfikator pracownika oraz ocenê
--liczbow¹ i jej opis.
--Zmodyfikuj poprzednie zapytanie tak aby pokazaæ tylko pracowników z
--departamentów 101, 102, 103 lub bez departamentu.

select e.employee_id, g.grade, g.description
from employees e cross join grades g
where e.department_id in (101, 102, 103) or e.department_id is null;

--ZnajdŸ pracowników, których zarobki nie s¹ zgodne z “wide³kami” na jego
--stanowisku. Zwróæ imiê, nazwisko, wynagrodzenie oraz nazwê stanowiska

--Zmodyfikuj poprzednie zapytanie tak, aby dodatkowo wyœwietliæ informacje
--o nazwie zak³adu pracownika.

select e.name, e.surname, e.salary, d.name, p.name
from employees e join positions p  using (position_id) join departments d using(department_id)
where e.salary not between p.min_salary and p.max_salary;

--Wyœwietl nazwê zak³adu wraz z imieniem i nazwiskiem jego kierowników.
--Poka¿ tylko zak³ady, które maj¹ bud¿et pomiêdzy 5000000 i 10000000.

select d.name, e.name, e.surname
from departments d join employees e on (d.manager_id = e.employee_id)
where d.year_budget between 5000000 and 10000000;

--ZnajdŸ zak³ady (podaj ich nazwê), które maj¹ swoje siedziby w Polsce.
select d.name
from departments d
join addresses a using (address_id)
join countries c using (country_id)
where c.name like 'Polska';

-- Zmodyfikuj zapytanie 3 tak, aby uwzglêdniaæ w wynikach tylko zak³ady,
--które maj¹ siedziby w Polsce.
select d.name, e.name, e.surname
from departments d 
join employees e on (d.manager_id = e.employee_id)
join addresses a using (address_id)
join countries c using (country_id)
where d.year_budget between 5000000 and 10000000
and c.name like 'Polska';

-- Poka¿ oceny (grades) pracowników którzy nie posiadaj¹ kierownika. W
--wynikach poka¿ imie , nazwisko pracownika, ocene liczbowa i jej opis.

select e.name, e.surname, g.grade, g.description
from employees e
join emp_grades using (employee_id)
join grades g using (grade_id)
where e.manager_id is NULL;

--Poka¿ nazwê kraju i nazwê regionu do którego zosta³ przypisany.
select * from reg_countries rc natural join regions r join countries c on (c.country_id = rc.country_id);

--Wyœwietl listê zawieraj¹c¹ nazwisko pracownika, stanowisko, na którym
--pracuje, aktualne zarobki oraz wide³ki p³acowe dla tego stanowiska.
--Steruj¹c rodzajem z³¹czenia, zagwarantuj, ¿e w wynikach znajd¹ siê
--wszyscy pracownicy

select e.surname, p.name, e.salary, p.max_salary, p.min_salary
from employees e
left join positions p using (position_id);


--Wyœwietl œredni¹ pensjê oraz liczbê osób zatrudnionych dla stanowisk.
--Steruj¹c rodzajem z³¹czenia zagwarantuj, ¿e znajd¹ siê tam równie¿
--stanowiska, na których nikt nie jest zatrudniony

select avg(e.salary), count(e.employee_id) from positions p left outer join employees e on (e.position_id = p.position_id) group by p.position_id;

--Poka¿ liczbê pracowników zatrudnionych kiedykolwiek w ka¿dym projekcie.
--Zadbaj by w wynikach pojawi³ siê ka¿dy projekt.

select count(employee_id), p.name
from employees e
join emp_projects using (employee_id)
right join projects p using (project_id)
group by project_id, p.name;

-- Poka¿ œredni¹ ocenê pracowników per departament. W wynikach zamiesc
--nazwe departamentu i srednia ocene.

select avg(g.grade), d.name
from grades g
join emp_grades using (grade_id)
join employees e using (employee_id)
right join departments d using (department_id)
group by department_id, d.name;

--Dla ka¿dego imienia pracownika z zak³adów Administracja lub Marketing zwróæ
--liczbê pracowników, którzy maj¹ takie samo imiê i podaj ich œrednie zarobki

select e.name, count(e.name), avg(e.salary)
from employees e
join departments d using (department_id)
where d.name in ('Administracja', 'Marketing')
group by e.name;

--Zwróæ imiona i nazwiska pracowników, którzy przeszli wiêcej ni¿ 2 zmiany
--stanowiska. Wyniki posortuj malej¹co wg liczby zmian.

select e.name, e.surname, count(*) changes
from employees e
join positions_history using (employee_id)
group by (employee_id, e.name, e.surname)
having count(*) > 2
order by changes desc;

--Zwróæ id, nazwisko kierowników oraz liczbê podleg³ych pracowników. Wyniki
--posortuj malej¹co wg liczby podleg³ych pracowników. 

select m.employee_id, m.name, m.surname, count(*)
from employees e
join employees m on (m.employee_id = e.manager_id)
group by (m.employee_id, m.name, m.surname)
order by count(*) desc;


-- Napisz zapytanie zwracaj¹ce liczbê zak³adów w krajach. W wynikach podaj
--nazwê kraju oraz jego ludnoœæ.

select c.name, c.population, count(*)
from departments d
join addresses a using (address_id)
right join countries c using (country_id)
group by country_id, c.name, c.population;


--. Napisz zapytanie zwracaj¹ce liczbê zak³adów w regionach. W wynikach podaj
--nazwê regionu. Wynik posortuj malej¹co wzglêdem liczby zak³adów.

select r.region_id, count(d.department_id) from regions r 
left outer join reg_countries rc on (r.region_id = rc.region_id)
left outer join addresses a on (rc.country_id = a.country_id)
join departments d on (d.address_id = a.address_id)
group by r.region_id order by count(d.department_id) desc;


-- PRACA DOMOWA

-- Napisz zapytanie znajduj¹ce liczbê zmian stanowisk pracownika Jan Kowalski.

select count(*) changes
from employees e
join positions_history using (employee_id)
where e.name like 'Jan' and e.surname like 'Kowalski';

--Napisz zapytanie znajduj¹ce œredni¹ pensjê dla ka¿dego ze stanowisk. Wynik
--powinien zawieraæ nazwê stanowiska i zaokr¹glon¹ œredni¹ pensjê.

select p.name, ROUND(avg(salary))
from positions p
join employees e using (position_id)
group by p.name, position_id;

-- Pobierz wszystkich pracowników zak³adu Kadry lub Finanse wraz z informacj¹ w
--jakim zak³adzie pracuj¹

select e.name, e.surname, d.name
from employees e
join departments d using (department_id)
where d.name in ('Kadry', 'Finanse');

--ZnajdŸ pracowników, których zarobki nie s¹ zgodne z “wide³kami” na jego
--stanowisku. Zwróæ imiê, nazwisko, wynagrodzenie oraz nazwê stanowiska.
--Zrealizuj za pomoc¹ z³¹czenia nierównoœciowego.

select e.name, e.surname, e.salary, p.name
from employees e 
left join positions p using (position_id)
where e.salary not between p.min_salary and p.max_salary;

--Poka¿ nazwy regionów w których nie ma ¿adnego kraju.

select r.name
from regions r 
left join reg_countries rc using (region_id)
where rc.country_id is null;

-- Wykonaj z³¹czenie naturalne miêdzy tabelami countries a regions. Jaki wynik
--otrzymujemy i dlaczego?
select *
from countries natural join regions;

-- Otrzymujemy pust¹ tabelê, poniewa¿ ³¹czymy tabele po wspólnej nazwie - name
-- nie ma regionu o takiej samej nazwie jak kraj

--Jaki otrzymamy wynik jeœli zrobimy NATURAL JOIN na tabelach bez wspólnej
--kolumny? SprawdŸ i zastanów siê nad przyczyn¹

select *
from positions natural join grades;

-- wykona³ siê cross join, poniewa¿ nie ma wspólnej kolumny





