--Napisz prosty blok anonimowy zawieraj¹cy blok wykonawczy z instrukcj¹
--NULL. Uruchom ten program.
BEGIN
NULL;
END;
/

--Zmodyfikuj program powy¿ej i wykorzystaj procedurê dbms_output.put_line
--przyjmuj¹c¹ jako parametr ³añcuch znakowy do wyœwietlenia na konsoli.
--Uruchom program i odnajdŸ napis.
BEGIN
dbms_output.put_line('test');
END;
/

--Napisz blok anonimowy który doda do tabeli region nowy rekord (np.
--‘Oceania’). Uruchom program i zweryfikuj dzia³anie.
BEGIN
INSERT INTO regions VALUES (303, 'Oceania', 'OCN');
END;
/

--Napisz blok anonimowy, który wygeneruje b³¹d
--(RAISE_APPLICATION_ERROR przyjmuj¹c¹ 2 parametry: kod b³êdu oraz
--wiadomoœæ)

BEGIN
RAISE_APPLICATION_ERROR(-20001, 'Error');
END;
/

--Napisz blok anonimowy który bêdzie korzysta³ z dwóch zmiennych (v_min_sal
--oraz v_emp_id) i który bêdzie wypisywa³ na ekran imiê i nazwisko pracownika
--o wskazanym id tylko jeœli jego zarobki s¹ wy¿sze ni¿ v_min_sal.
DECLARE
    v_min_sal NUMBER := 15000;
    v_emp_id NUMBER := 101;
    v_name employees.name%TYPE;
    v_surname employees.surname%TYPE;
    v_salary employees.salary%TYPE;
BEGIN
    SELECT name, surname, salary
    INTO v_name, v_surname, v_salary
    FROM employees
    WHERE v_emp_id = employee_id;
    IF v_salary > v_min_sal THEN
        dbms_output.put_line('Name: ' || v_name || ' Surname: ' || v_surname);
    ELSE
        dbms_output.put_line('No data found');
    END IF;
END;
/

--Napisz funkcjê, która wyliczy roczn¹ wartoœæ podatku pracownika. Zak³adamy
--podatek progresywny. Pocz¹tkowo stawka to 15%, po przekroczeniu progu
--100000 stawka wynosi 25%.

create or replace function calculate_tax(emp_id NUMBER)
return number
as
    c_first_limit NUMBER := 100000;
    v_year_salary NUMBER;
    v_tax NUMBER;
begin
    select 12 * salary
    into v_year_salary
    from employees
    where emp_id = employee_id;
    if v_year_salary < c_first_limit then
        v_tax := 0.15 * v_year_salary;
    else
        v_tax := 0.15 * c_first_limit + 0.25 * (v_year_salary - c_first_limit);
    end if;
return v_tax;
end;
/
select calculate_tax(101) from dual;
/

--Stwórz widok ³¹cz¹cy departamenty, adresy i kraje. Napisz zapytanie, które
--poka¿e sumê zap³aconych podatków w krajach.
select c.name, sum(calculate_tax(e.employee_id))
from employees e
join departments d on (e.department_id = d.department_id)
join addresses a on (d.address_id = a.address_id)
join countries c on (a.country_id = c.country_id)
group by c.country_id, c.name;
/

--Napisz funkcjê, która wyliczy dodatek funkcyjny dla kierowników zespo³ów.
--Dodatek funkcyjny powinien wynosiæ 10% pensji za ka¿dego podleg³ego
--pracownika, ale nie mo¿e przekraczaæ 50% miesiêcznej pensji.
create or replace function calculate_function_bonus(man_id NUMBER)
return number
as
    v_emp_number NUMBER;
    v_salary NUMBER;
    v_bonus NUMBER;
begin
    select count(*)
    into v_emp_number
    from employees
    where manager_id = man_id;
    select salary
    into v_salary
    from employees
    where employee_id = man_id;
    v_bonus := v_emp_number * (v_salary * 0.1);
    if v_bonus > 0.5 * v_salary then
        v_bonus := 0.5 * v_salary;
    end if;
return v_bonus;
end;
/
select calculate_function_bonus(103) from dual;
/

--Zmodyfikuj funkcjê calculate_total_bonus, ¿eby wylicza³a ca³oœæ dodatku
--dla pracownika (sta¿owy i funkcyjny).
CREATE OR replace FUNCTION calculate_seniority_bonus(p_id NUMBER)
RETURN NUMBER
AS
 v_age NUMBER;
 v_yrs_employed NUMBER;
 v_birth_date DATE;
 v_date_employed DATE;
 v_salary NUMBER;
 v_bonus NUMBER := 0;
 c_sal_multiplier CONSTANT NUMBER := 2;
 c_age_min CONSTANT NUMBER := 30;
 c_emp_min CONSTANT NUMBER := 3;
BEGIN
 SELECT birth_date,date_employed, salary
 INTO v_birth_date, v_date_employed, v_salary
 FROM employees
 WHERE employee_id = p_id;
 v_age := extract (year FROM SYSDATE) - extract (year FROM v_birth_date);
 v_yrs_employed := extract (year FROM SYSDATE) - extract (year FROM v_date_employed);
 IF v_age > c_age_min AND v_yrs_employed > c_emp_min THEN
 v_bonus := c_sal_multiplier * v_salary;
 END IF;
 RETURN v_bonus;
END;
/

CREATE OR replace FUNCTION calculate_total_bonus(p_id NUMBER)
RETURN NUMBER
AS
 v_sen_bonus NUMBER;
 v_fun_bonus NUMBER;
BEGIN
 v_sen_bonus := calculate_seniority_bonus(p_id);
 v_fun_bonus := calculate_function_bonus(p_id);
 RETURN v_sen_bonus + v_fun_bonus;
END;
/

--Napisz procedurê, która wykona zmianê stanowiska pracownika. Procedura
--powinna przyjmowaæ identyfikator pracownika oraz identyfikator jego nowego
--stanowiska.

create or replace procedure change_position(emp_id NUMBER, pos_id NUMBER)
as
begin
    update employees set position_id = pos_id where employee_id = emp_id;
end;
/
begin
    change_position(101, 101);
end;
/
--Napisz procedurê, która zdegraduje zespo³owego kierownika o danym
--identyfikatorze. Na nowego kierownika zespo³u powo³aj najstarszego z jego
--dotychczasowych podw³adnych.

create or replace procedure degrade_manager(man_id number)
as
    v_oldest_id NUMBER;
begin
    select employee_id
    into v_oldest_id
    from employees
    where manager_id = 101
    order by birth_date asc
    fetch next 1 rows only;
    
    update employees set manager_id = v_oldest_id where employee_id = man_id;
    update employees set manager_id = v_oldest_id where manager_id = man_id;
    update employees set manager_id = NULL where employee_id = v_oldest_id;
end;
/
select employee_id
from employees
where manager_id = 101;
/
begin
    degrade_manager(101);
end;
/
rollback;
/

--Napisz funkcjê, która bêdzie tworzy³a bazowy login dla ka¿dego pracownika.
--Login ma siê sk³adaæ z pierwszej litery imienia i maksymalnie 7 znaków z
--nazwiska.

create or replace function create_login(emp_id number)
return varchar
as
   v_login varchar(8);
   v_name employees.name%TYPE;
   v_surname employees.surname%TYPE;
begin
    select name, surname
    into v_name, v_surname
    from employees
    where employee_id = emp_id;
    
    v_login := CONCAT(SUBSTR(v_name, 0, 1), SUBSTR(v_surname, 0, 7));
    
return v_login;
end;
/
select create_login(101) from dual;
/

--Napisz procedurê, która bêdzie zapisywaæ login pracownika do nowej
--kolumny w tabeli employees (dodaj j¹). Zadbaj o to, ¿eby zapisywany login
--by³ unikalny (np. poprzez dodanie numerów do bazowego loginu).
/
alter table employees add login VARCHAR(15);
/
create or replace procedure add_login(emp_id number)
as
    v_login varchar(15);
begin
    v_login := CONCAT(create_login(emp_id), emp_id);
    update employees set login = v_login where employee_id = emp_id;
end;
/
begin
    add_login(101);
end;
/









