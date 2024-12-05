--Creating an enumerated list which will be useful for the trigger function
CREATE TYPE operation_enum AS ENUM ('Insert', 'Update', 'Delete');

--Creating the audit table

CREATE TABLE employee_audit(
audit_id INTEGER NOT NULL,
name TEXT NOT NULL,
department TEXT NOT NULL,
old_salary decimal(10,2),
new_salary decimal (10,2),
time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
user_id TEXT NOT NULL,
operation_type operation_enum NOT NULL
)

--Creating a Sequence
CREATE SEQUENCE employees_audit_seq
START WITH 1
INCREMENT BY 1

--Creating the Trigger Function 

CREATE OR REPLACE FUNCTION employee_check()
RETURNS TRIGGER AS $$
BEGIN 
	CASE TG_OP
		WHEN 'UPDATE' THEN
		INSERT INTO public.employee_audit(audit_id,name,department,old_salary,new_salary,time, user_id,operation_type)
		VALUES (NEXTVAL('employees_audit_seq'), OLD.name, OLD.department, OLD.salary, NEW.salary, NOW(), current_user, 'Update');

		WHEN 'INSERT' THEN
		INSERT INTO public.employee_audit(audit_id,name,department,old_salary,new_salary,time, user_id,operation_type)
		VALUES (NEXTVAL('employees_audit_seq'), NEW.name, NEW.department, NULL, NEW.salary, NOW(), current_user, 'Insert');

		WHEN 'DELETE' THEN
		INSERT INTO public.employee_audit(audit_id,name,department,old_salary,new_salary,time, user_id,operation_type)
		VALUES (NEXTVAL('employees_audit_seq'), OLD.name, OLD.department, OLD.salary, NULL, NOW(), current_user, 'Delete');
	END CASE;
	RETURN NULL;
END;
$$
LANGUAGE PLPGSQL;


CREATE TRIGGER employee_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION employee_check();

--Testing Trigger to check if it's functional using a transaction

BEGIN;
UPDATE public.employees
SET salary = 10000
WHERE emp_id = 3;

--Checking my audit table to see changes that occurred
TABLE public.employee_audit;

--Commiting the transaction
COMMIT;

--Testing additional operations
INSERT INTO employees (emp_id, name, department, salary) 
VALUES (11, 'Kevin', 'IT', 7000.00);

DELETE FROM employees WHERE emp_id = 2;

--Audit Table Validation
SELECT * 
FROM employee_audit
ORDER BY time DESC;
