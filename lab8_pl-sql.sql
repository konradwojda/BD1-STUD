--Napisz prosty blok anonimowy zawieraj�cy blok wykonawczy z instrukcj�
--NULL. Uruchom ten program.
BEGIN
NULL;
END;
/

--Zmodyfikuj program powy�ej i wykorzystaj procedur� dbms_output.put_line
--przyjmuj�c� jako parametr �a�cuch znakowy do wy�wietlenia na konsoli.
--Uruchom program i odnajd� napis.
BEGIN
dbms_output.put_line('test');
END;
/

--Napisz blok anonimowy kt�ry doda do tabeli region nowy rekord (np.
--�Oceania�). Uruchom program i zweryfikuj dzia�anie.
BEGIN
INSERT INTO regions VALUES (303, 'Oceania', 'OCN');
END;
/

--Napisz blok anonimowy, kt�ry wygeneruje b��d
--(RAISE_APPLICATION_ERROR przyjmuj�c� 2 parametry: kod b��du oraz
--wiadomo��)

BEGIN
RAISE_APPLICATION_ERROR(-20001, 'Error');
END;
/

--Napisz blok anonimowy kt�ry b�dzie korzysta� z dw�ch zmiennych (v_min_sal
--oraz v_emp_id) i kt�ry b�dzie wypisywa� na ekran imi� i nazwisko pracownika
--o wskazanym id tylko je�li jego zarobki s� wy�sze ni� v_min_sal.
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

--Napisz funkcj�, kt�ra wyliczy roczn� warto�� podatku pracownika. Zak�adamy
--podatek progresywny. Pocz�tkowo stawka to 15%, po przekroczeniu progu
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

--Stw�rz widok ��cz�cy departamenty, adresy i kraje. Napisz zapytanie, kt�re
--poka�e sum� zap�aconych podatk�w w krajach.
select c.name, sum(calculate_tax(e.employee_id))
from employees e
join departments d on (e.department_id = d.department_id)
join addresses a on (d.address_id = a.address_id)
join countries c on (a.country_id = c.country_id)
group by c.country_id, c.name;
/

--Napisz funkcj�, kt�ra wyliczy dodatek funkcyjny dla kierownik�w zespo��w.
--Dodatek funkcyjny powinien wynosi� 10% pensji za ka�dego podleg�ego
--pracownika, ale nie mo�e przekracza� 50% miesi�cznej pensji.
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

--Zmodyfikuj funkcj� calculate_total_bonus, �eby wylicza�a ca�o�� dodatku
--dla pracownika (sta�owy i funkcyjny).
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

--Napisz procedur�, kt�ra wykona zmian� stanowiska pracownika. Procedura
--powinna przyjmowa� identyfikator pracownika oraz identyfikator jego nowego
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
--Napisz procedur�, kt�ra zdegraduje zespo�owego kierownika o danym
--identyfikatorze. Na nowego kierownika zespo�u powo�aj najstarszego z jego
--dotychczasowych podw�adnych.

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

--Napisz funkcj�, kt�ra b�dzie tworzy�a bazowy login dla ka�dego pracownika.
--Login ma si� sk�ada� z pierwszej litery imienia i maksymalnie 7 znak�w z
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

--Napisz procedur�, kt�ra b�dzie zapisywa� login pracownika do nowej
--kolumny w tabeli employees (dodaj j�). Zadbaj o to, �eby zapisywany login
--by� unikalny (np. poprzez dodanie numer�w do bazowego loginu).
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









