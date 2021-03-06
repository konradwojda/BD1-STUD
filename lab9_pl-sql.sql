--Uzupe?nij cia?o pakietu z poprzedniego slajdu za pomoc? definicji funkcji
--calculate_seniority_bonus oraz procedury add_candidate, kt?re pojawi?y si? na
--poprzednich zaj?ciach. Nast?pnie wywo?aj te podprogramy z wykorzystaniem
--nazwy pakietu.

--Dodaj do pakietu prywatn? funkcj? create_base_login, kt?ra b?dzie
--generowa?a bazowy login pracownika (?wiczenie z pracy domowej BD1_8).
--Sprawd? mo?liwo?? wywo?ania tej funkcji.

CREATE OR REPLACE PACKAGE emp_management
AS
FUNCTION calculate_seniority_bonus (p_id NUMBER) RETURN NUMBER;
PROCEDURE add_candidate (p_name VARCHAR2, p_surname VARCHAR2, p_birth_date DATE, p_gender
VARCHAR2, p_pos_name VARCHAR2, p_dep_name VARCHAR2);
END;
/
CREATE OR REPLACE PACKAGE BODY emp_management
AS
FUNCTION calculate_seniority_bonus(p_id NUMBER) RETURN NUMBER
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
END calculate_seniority_bonus;
PROCEDURE add_candidate (p_name VARCHAR2, p_surname VARCHAR2, p_birth_date DATE,
p_gender VARCHAR2, p_pos_name VARCHAR2, p_dep_name VARCHAR2)
AS
    v_pos_id
    NUMBER; v_dep_id
    NUMBER; v_cand_num NUMBER;
    c_candidate_status CONSTANT NUMBER := 304;
    c_num_max CONSTANT NUMBER := 2;
BEGIN
    SELECT position_id
    INTO v_pos_id 
    FROM positions WHERE name = p_pos_name;
    SELECT department_id 
    INTO v_dep_id 
    FROM departments WHERE name = p_dep_name;
    SELECT count(employee_id) INTO
    v_cand_num
    FROM
    employees
    WHERE department_id = v_dep_id AND status_id = c_candidate_status;
    IF v_cand_num < c_num_max THEN
        INSERT INTO employees
        VALUES (NULL, p_name, p_surname, p_birth_date, p_gender, c_candidate_status, NULL, NULL, v_dep_id, v_pos_id, NULL, NULL);
        dbms_output.put_line ('Dodano kandydata '|| p_name|| ' '|| p_surname);
    ELSE
        dbms_output.put_line ('Za duzo kandydat?w w departamencie: '|| p_dep_name);
    END IF;
    EXCEPTION
        WHEN no_data_found THEN
        dbms_output.put_line ('Niepoprawna nazwa stanowiska i/lub zak?adu');
        RAISE;
        WHEN too_many_rows THEN
        dbms_output.put_line ('Nieunikalna nazwa stanowiska i/lub zak?adu');
        RAISE;
END add_candidate;
function create_login(emp_id number)
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
end create_login;
END emp_management;
/

select emp_management.calculate_seniority_bonus(101) from dual;

/

select emp_management.create_login(101) from dual;
-- Nie mo?na wywo?a? 
/

--Stw?rz wyzwalacz, kt?ry podczas uaktualniania zarobk?w pracownika wy?wietli
--podatek 20% procent od nowych zarobk?w. Przetestuj dzia?anie.

create or replace trigger tg_tax
after update of salary on employees
for each row
declare
begin
    dbms_output.put_line(0.2 * :new.salary);
end tg_tax;
/
update employees set salary = 6000 where employee_id = 101;
/

--Stw?rz wyzwalacz, kt?ry po dodaniu nowego pracownika, usuni?ciu pracownika lub
--modyfikacji zarobk?w pracownik?w wy?wietli aktualne ?rednie zarobki wszystkich
--pracownik?w. Przetestuj dzia?anie.
create or replace trigger tg_avg_sal
after insert or delete or update of salary on employees
declare
    v_avg_sal NUMBER;
begin
    select avg(salary)
    into v_avg_sal
    from employees;
    dbms_output.put_line(v_avg_sal);
end tg_avg_tax;
/

update employees set salary = 5500 where employee_id = 101;

/

--Stw?rz wyzwalacz, kt?ry dla ka?dego nowego pracownika nieposiadaj?cego managera,
--ale zatrudnionego w departamencie, przypisze temu pracownikowi managera
--b?d?cego jednocze?nie managerem departamentu, w kt?rym ten pracownik pracuje.
--Wykorzystaj klauzul? WHEN wyzwalacza. Przetestuj dzia?anie.

create or replace trigger tg_man
before insert on employees
for each row
when (new.manager_id IS NULL and new.department_id IS NOT NULL)
declare
    v_man_id departments.manager_id%TYPE;
begin
    select manager_id
    into v_man_id
    from departments d
    where d.department_id = :new.department_id;
    
    :new.manager_id := v_man_id;

end tg_man;
    
/

insert into employees values (160, 'Adam', 'Abacki', '01/01/01', 'M', NULL, 5000, NULL, 101, NULL, NULL, NULL);
/

--Rozwi?? ponownie ?wiczenie nr 4, ale tym razem nie wykorzystuj klauzuli WHEN
--wyzwalacza. Przetestuj dzia?anie.

create or replace trigger tg_man
before insert on employees
for each row
declare
    v_man_id departments.manager_id%TYPE;
begin
if (:new.manager_id IS NULL and :new.department_id IS NOT NULL) then
    select manager_id
    into v_man_id
    from departments d
    where d.department_id = :new.department_id;
    
    :new.manager_id := v_man_id;
end if;
end tg_man;
/
insert into employees values (160, 'Adam', 'Abacki', '01/01/01', 'M', NULL, 5000, NULL, 101, NULL, NULL, NULL);
/

--Stw?rz wyzwalacz kt?ry b?dzie weryfikowa?, ?e w firmie pracuje tylko jeden Prezes.

-- sk?d wiadomo kto jest prezesem?

--Przygotuj procedur? PL/SQL, kt?ra z wykorzystaniem jawnego kursora
--udost?pni ?rednie zarobki dla ka?dego z departament?w. Nast?pnie
--wykorzystuj?c ten kursor wy?wietl imiona, nazwiska i zarobki pracownik?w,
--kt?rzy zarabiaj? wi?cej ni? ?rednie zarobki w ich departamentach.


declare

v_avg_sal_by_dep department%ROWTYPE;

cursor cr is
    select avg(salary)
    from departments
    group by department_id;
    
begin
    open cr;
    
/










