7 Performing SQL Operations with Native Dynamic SQL
This chapter describes how to use native dynamic SQL (dynamic SQL for short) with PL/SQL to make your programs more flexible, by building and processing SQL statements at run time.
With dynamic SQL, you can directly execute most types of SQL statement, including data definition and data control statements. You can build statements in which you do not know table names, WHERE clauses, and other information in advance.
This chapter contains these topics:
•	Why Use Dynamic SQL with PL/SQL?
•	Using the EXECUTE IMMEDIATE Statement in PL/SQL
•	Using Bulk Dynamic SQL in PL/SQL
•	Guidelines for Using Dynamic SQL with PL/SQL
For additional information about dynamic SQL, see Oracle Database Application Developer's Guide - Fundamentals.
Why Use Dynamic SQL with PL/SQL?
Dynamic SQL enables you to build SQL statements dynamically at runtime. You can create more general purpose, flexible applications by using dynamic SQL because the full text of a SQL statement may be unknown at compilation.
To process most dynamic SQL statements, you use the EXECUTE IMMEDIATE statement. To process a multi-row query (SELECT statement), you use the OPEN-FOR, FETCH, and CLOSE statements.
You need dynamic SQL in the following situations:
•	You want to execute a SQL data definition statement (such as CREATE), a data control statement (such as GRANT), or a session control statement (such as ALTER SESSION). Unlike INSERT, UPDATE, and DELETE statements, these statements cannot be included directly in a PL/SQL program.
•	You want more flexibility. For example, you might want to pass the name of a schema object as a parameter to a procedure. You might want to build different search conditions for the WHERE clause of a SELECT statement.
•	You want to issue a query where you do not know the number, names, or datatypes of the columns in advance. In this case, you use the DBMS_SQL package rather than the OPEN-FOR statement.
If you have older code that uses the DBMS_SQL package, the techniques described in this chapter using EXECUTE IMMEDIATE and OPEN-FOR generally provide better performance, more readable code, and extra features such as support for objects and collections.
For a comparison of dynamic SQL with DBMS_SQL, see Oracle Database Application Developer's Guide - Fundamentals. For information on the DBMS_SQL package, see Oracle Database PL/SQL Packages and Types Reference.
Note:
Native dynamic SQL using the EXECUTE IMMEDIATE and OPEN-FOR statements is faster and requires less coding than the DBMS_SQL package. However, the DBMS_SQL package should be used in these situations: 
•	There is an unknown number of input or output variables, such as the number of column values returned by a query, that are used in a dynamic SQL statement (Method 4 for dynamic SQL).
•	The dynamic code is too large to fit inside a 32K bytes VARCHAR2 variable.
Using the EXECUTE IMMEDIATE Statement in PL/SQL
The EXECUTE IMMEDIATE statement prepares (parses) and immediately executes a dynamic SQL statement or an anonymous PL/SQL block. The main argument to EXECUTE IMMEDIATE is the string containing the SQL statement to execute. You can build up the string using concatenation, or use a predefined string.
Except for multi-row queries, the dynamic string can contain any SQL statement or any PL/SQL block. The string can also contain placeholders, arbitrary names preceded by a colon, for bind arguments. In this case, you specify which PL/SQL variables correspond to the placeholders with the INTO, USING, and RETURNING INTO clauses.
When constructing a single SQL statement in a dynamic string, do not include a semicolon (;) at the end inside the quotation mark. When constructing a PL/SQL anonymous block, include the semicolon at the end of each PL/SQL statement and at the end of the anonymous block; there will be a semicolon immediately before the end of the string literal, and another following the closing single quotation mark.
You can only use placeholders in places where you can substitute variables in the SQL statement, such as conditional tests in WHERE clauses. You cannot use placeholders for the names of schema objects. For the right way, see "Passing Schema Object Names As Parameters".
Used only for single-row queries, the INTO clause specifies the variables or record into which column values are retrieved. For each value retrieved by the query, there must be a corresponding, type-compatible variable or field in the INTO clause.
Used only for DML statements that have a RETURNING clause (without a BULK COLLECT clause), the RETURNING INTO clause specifies the variables into which column values are returned. For each value returned by the DML statement, there must be a corresponding, type-compatible variable in the RETURNING INTO clause.
You can place all bind arguments in the USING clause. The default parameter mode is IN. For DML statements that have a RETURNING clause, you can place OUT arguments in the RETURNING INTO clause without specifying the parameter mode. If you use both the USING clause and the RETURNING INTO clause, the USING clause can contain only IN arguments.
At run time, bind arguments replace corresponding placeholders in the dynamic string. Every placeholder must be associated with a bind argument in the USING clause and/or RETURNING INTO clause. You can use numeric, character, and string literals as bind arguments, but you cannot use Boolean literals (TRUE, FALSE, and NULL). To pass nulls to the dynamic string, you must use a workaround. See "Passing Nulls to Dynamic SQL".
Dynamic SQL supports all the SQL datatypes. For example, define variables and bind arguments can be collections, LOBs, instances of an object type, and refs.
As a rule, dynamic SQL does not support PL/SQL-specific types. For example, define variables and bind arguments cannot be Booleans or associative arrays. The only exception is that a PL/SQL record can appear in the INTO clause.
You can execute a dynamic SQL statement repeatedly using new values for the bind arguments. However, you incur some overhead because EXECUTE IMMEDIATE re-prepares the dynamic string before every execution.
For more information on EXECUTE IMMEDIATE, see "EXECUTE IMMEDIATE Statement".
Example 7-1 illustrates several uses of dynamic SQL.
Example 7-1 Examples of Dynamic SQL
CREATE OR REPLACE PROCEDURE raise_emp_salary (column_value NUMBER, 
                             emp_column VARCHAR2, amount NUMBER) IS
   v_column VARCHAR2(30);
   sql_stmt  VARCHAR2(200);
BEGIN
-- determine if a valid column name has been given as input
  SELECT COLUMN_NAME INTO v_column FROM USER_TAB_COLS 
    WHERE TABLE_NAME = 'EMPLOYEES' AND COLUMN_NAME = emp_column;
  sql_stmt := 'UPDATE employees SET salary = salary + :1 WHERE ' 
               || v_column || ' = :2';
  EXECUTE IMMEDIATE sql_stmt USING amount, column_value;
  IF SQL%ROWCOUNT > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Salaries have been updated for: ' || emp_column 
                        || ' = ' || column_value);
  END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE ('Invalid Column: ' || emp_column);
END raise_emp_salary;
/

DECLARE
   plsql_block       VARCHAR2(500);
BEGIN
-- note the semi-colons (;) inside the quotes '...'
  plsql_block := 'BEGIN raise_emp_salary(:cvalue, :cname, :amt); END;';
  EXECUTE IMMEDIATE plsql_block USING 110, 'DEPARTMENT_ID', 10;
  EXECUTE IMMEDIATE 'BEGIN raise_emp_salary(:cvalue, :cname, :amt); END;'
      USING 112, 'EMPLOYEE_ID', 10;
END;
/

DECLARE
   sql_stmt          VARCHAR2(200);
   v_column          VARCHAR2(30) := 'DEPARTMENT_ID';
   dept_id           NUMBER(4) := 46;
   dept_name         VARCHAR2(30) := 'Special Projects';
   mgr_id            NUMBER(6) := 200;
   loc_id            NUMBER(4) := 1700;
BEGIN
-- note that there is no semi-colon (;) inside the quotes '...'
  EXECUTE IMMEDIATE 'CREATE TABLE bonus (id NUMBER, amt NUMBER)';
  sql_stmt := 'INSERT INTO departments VALUES (:1, :2, :3, :4)';
  EXECUTE IMMEDIATE sql_stmt USING dept_id, dept_name, mgr_id, loc_id;
  EXECUTE IMMEDIATE 'DELETE FROM departments WHERE ' || v_column || ' = :num'
      USING dept_id;
  EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE TRUE';
  EXECUTE IMMEDIATE 'DROP TABLE bonus';
END;
/

In Example 7-2, a standalone procedure accepts the name of a database table and an optional WHERE-clause condition. If you omit the condition, the procedure deletes all rows from the table. Otherwise, the procedure deletes only those rows that meet the condition.
Example 7-2 Dynamic SQL Procedure that Accepts Table Name and WHERE Clause
CREATE TABLE employees_temp AS SELECT * FROM employees;

CREATE OR REPLACE PROCEDURE delete_rows (
   table_name IN VARCHAR2,
   condition  IN VARCHAR2 DEFAULT NULL) AS
   where_clause  VARCHAR2(100) := ' WHERE ' || condition;
   v_table      VARCHAR2(30);
BEGIN
-- first make sure that the table actually exists; if not, raise an exception
  SELECT OBJECT_NAME INTO v_table FROM USER_OBJECTS
    WHERE OBJECT_NAME = UPPER(table_name) AND OBJECT_TYPE = 'TABLE';
   IF condition IS NULL THEN where_clause := NULL; END IF;
   EXECUTE IMMEDIATE 'DELETE FROM ' || v_table || where_clause;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE ('Invalid table: ' || table_name);
END;
/
BEGIN
  delete_rows('employees_temp', 'employee_id = 111');
END;
/

Specifying Parameter Modes for Bind Variables in Dynamic SQL Strings
With the USING clause, the mode defaults to IN, so you do not need to specify a parameter mode for input bind arguments.
With the RETURNING INTO clause, the mode is OUT, so you cannot specify a parameter mode for output bind arguments.
You must specify the parameter mode in more complicated cases, such as this one where you call a procedure from a dynamic PL/SQL block:
CREATE PROCEDURE create_dept (
   deptid IN OUT NUMBER,
   dname  IN VARCHAR2,
   mgrid  IN NUMBER,
   locid  IN NUMBER) AS
BEGIN
   SELECT departments_seq.NEXTVAL INTO deptid FROM dual;
   INSERT INTO departments VALUES (deptid, dname, mgrid, locid);
END;
/

To call the procedure from a dynamic PL/SQL block, you must specify the IN OUT mode for the bind argument associated with formal parameter deptid, as shown in Example 7-3.
Example 7-3 Using IN OUT Bind Arguments to Specify Substitutions
DECLARE
   plsql_block VARCHAR2(500);
   new_deptid  NUMBER(4);
   new_dname   VARCHAR2(30) := 'Advertising';
   new_mgrid   NUMBER(6) := 200;
   new_locid   NUMBER(4) := 1700;
BEGIN
   plsql_block := 'BEGIN create_dept(:a, :b, :c, :d); END;';
   EXECUTE IMMEDIATE plsql_block
      USING IN OUT new_deptid, new_dname, new_mgrid, new_locid;
END;
/

Using Bulk Dynamic SQL in PL/SQL
Bulk SQL passes entire collections back and forth, not just individual elements. This technique improves performance by minimizing the number of context switches between the PL/SQL and SQL engines. You can use a single statement instead of a loop that issues a SQL statement in every iteration.
Using the following commands, clauses, and cursor attribute, your applications can construct bulk SQL statements, then execute them dynamically at run time:

BULK FETCH statement
BULK EXECUTE IMMEDIATE statement
FORALL statement
COLLECT INTO clause
RETURNING INTO clause
%BULK_ROWCOUNT cursor attribute
The static versions of these statements, clauses, and cursor attribute are discussed in "Reducing Loop Overhead for DML Statements and Queries with Bulk SQL". Refer to that section for background information.
Using Dynamic SQL with Bulk SQL
Bulk binding lets Oracle bind a variable in a SQL statement to a collection of values. The collection type can be any PL/SQL collection type: index-by table, nested table, or varray. The collection elements must have a SQL datatype such as CHAR, DATE, or NUMBER. Three statements support dynamic bulk binds: EXECUTE IMMEDIATE, FETCH, and FORALL.
EXECUTE IMMEDIATE
You can use the BULK COLLECT INTO clause with the EXECUTE IMMEDIATE statement to store values from each column of a query's result set in a separate collection.
You can use the RETURNING BULK COLLECT INTO clause with the EXECUTE IMMEDIATE statement to store the results of an INSERT, UPDATE, or DELETE statement in a set of collections.
FETCH
You can use the BULK COLLECT INTO clause with the FETCH statement to store values from each column of a cursor in a separate collection.
FORALL
You can put an EXECUTE IMMEDIATE statement with the RETURNING BULK COLLECT INTO inside a FORALL statement. You can store the results of all the INSERT, UPDATE, or DELETE statements in a set of collections.
You can pass subscripted collection elements to the EXECUTE IMMEDIATE statement through the USING clause. You cannot concatenate the subscripted elements directly into the string argument to EXECUTE IMMEDIATE; for example, you cannot build a collection of table names and write a FORALL statement where each iteration applies to a different table.
Examples of Dynamic Bulk Binds
This sections contains examples of dynamic bulk binds.You can bind define variables in a dynamic query using the BULK COLLECT INTO clause. As shown in Example 7-4, you can use that clause in a bulk FETCH or bulk EXECUTE IMMEDIATE statement.
Example 7-4 Dynamic SQL with BULK COLLECT INTO Clause

DECLARE
   TYPE EmpCurTyp IS REF CURSOR;
   TYPE NumList IS TABLE OF NUMBER;
   TYPE NameList IS TABLE OF VARCHAR2(25);
   emp_cv EmpCurTyp;
   empids NumList;
   enames NameList;
   sals   NumList;
BEGIN
   OPEN emp_cv FOR 'SELECT employee_id, last_name FROM employees';
   FETCH emp_cv BULK COLLECT INTO empids, enames;
   CLOSE emp_cv;
   EXECUTE IMMEDIATE 'SELECT salary FROM employees'
      BULK COLLECT INTO sals;
END;


Only INSERT, UPDATE, and DELETE statements can have output bind variables. You bulk-bind them with the RETURNING BULK COLLECT INTO clause of EXECUTE IMMEDIATE, as shown in Example 7-5.
Example 7-5 Dynamic SQL with RETURNING BULK COLLECT INTO Clause

DECLARE
   TYPE NameList IS TABLE OF VARCHAR2(15);
   enames    NameList;
   bonus_amt NUMBER := 50;
   sql_stmt  VARCHAR(200);
BEGIN
   sql_stmt := 'UPDATE employees SET salary = salary + :1 
                RETURNING last_name INTO :2';
   EXECUTE IMMEDIATE sql_stmt
      USING bonus_amt RETURNING BULK COLLECT INTO enames;
END;
/

To bind the input variables in a SQL statement, you can use the FORALL statement and USING clause, as shown in Example 7-6. The SQL statement cannot be a query.
Example 7-6 Dynamic SQL Inside FORALL Statement
DECLARE
   TYPE NumList IS TABLE OF NUMBER;
   TYPE NameList IS TABLE OF VARCHAR2(15);
   empids NumList;
   enames NameList;
BEGIN
   empids := NumList(101,102,103,104,105);
   FORALL i IN 1..5
      EXECUTE IMMEDIATE
        'UPDATE employees SET salary = salary * 1.04 WHERE employee_id = :1
         RETURNING last_name INTO :2'
         USING empids(i) RETURNING BULK COLLECT INTO enames;
END;
/
Guidelines for Using Dynamic SQL with PL/SQL
This section shows you how to take full advantage of dynamic SQL and how to avoid some common pitfalls.
Note:
When using dynamic SQL with PL/SQL, be aware of the risks of SQL injection, which is a possible security issue. For more information on SQL injection and possible problems, see Oracle Database Application Developer's Guide - Fundamentals. You can also search for "SQL injection" on the Oracle Technology Network at http://www.oracle.com/technology/
Building a Dynamic Query with Dynamic SQL
You use three statements to process a dynamic multi-row query: OPEN-FOR, FETCH, and CLOSE. First, you OPEN a cursor variable FOR a multi-row query. Then, you FETCH rows from the result set one at a time. When all the rows are processed, you CLOSE the cursor variable. For more information about cursor variables, see "Using Cursor Variables (REF CURSORs)".
When to Use or Omit the Semicolon with Dynamic SQL
When building up a single SQL statement in a string, do not include any semicolon at the end.
When building up a PL/SQL anonymous block, include the semicolon at the end of each PL/SQL statement and at the end of the anonymous block. For example:
BEGIN
   EXECUTE IMMEDIATE 'BEGIN DBMS_OUTPUT.PUT_LINE(''semicolons''); END;';
END;
/
Improving Performance of Dynamic SQL with Bind Variables
When you code INSERT, UPDATE, DELETE, and SELECT statements directly in PL/SQL, PL/SQL turns the variables into bind variables automatically, to make the statements work efficiently with SQL. When you build up such statements in dynamic SQL, you need to specify the bind variables yourself to get the same performance.
In the following example, Oracle opens a different cursor for each distinct value of emp_id. This can lead to resource contention and poor performance as each statement is parsed and cached.
CREATE PROCEDURE fire_employee (emp_id NUMBER) AS
BEGIN
   EXECUTE IMMEDIATE
      'DELETE FROM employees WHERE employee_id = ' || TO_CHAR(emp_id);
END;
/

You can improve performance by using a bind variable, which allows Oracle to reuse the same cursor for different values of emp_id:
CREATE PROCEDURE fire_employee (emp_id NUMBER) AS
BEGIN
   EXECUTE IMMEDIATE
      'DELETE FROM employees WHERE employee_id = :id' USING emp_id;
END;
/

Passing Schema Object Names As Parameters
Suppose you need a procedure that accepts the name of any database table, then drops that table from your schema. You must build a string with a statement that includes the object names, then use EXECUTE IMMEDIATE to execute the statement:
CREATE TABLE employees_temp AS SELECT last_name FROM employees;
CREATE PROCEDURE drop_table (table_name IN VARCHAR2) AS
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE ' || table_name;
END;
/

Use concatenation to build the string, rather than trying to pass the table name as a bind variable through the USING clause.
In addition, if you need to call a procedure whose name is unknown until runtime, you can pass a parameter identifying the procedure. For example, the following procedure can call another procedure (drop_table) by specifying the procedure name when executed.
CREATE PROCEDURE run_proc (proc_name IN VARCHAR2, table_name IN VARCHAR2) ASBEGIN
   EXECUTE IMMEDIATE 'CALL "' || proc_name || '" ( :proc_name )' using table_name;
END;
/

If you want to drop a table with the drop_table procedure, you can run the procedure as follows. Note that the procedure name is capitalized.
CREATE TABLE employees_temp AS SELECT last_name FROM employees;
BEGIN 
  run_proc('DROP_TABLE', 'employees_temp'); 
END;
/

Using Duplicate Placeholders with Dynamic SQL
Placeholders in a dynamic SQL statement are associated with bind arguments in the USING clause by position, not by name. If you specify a sequence of placeholders like :a, :a, :b, :b, you must include four items in the USING clause. For example, given the dynamic string
sql_stmt := 'INSERT INTO payroll VALUES (:x, :x, :y, :x)';
the fact that the name X is repeated is not significant. You can code the corresponding USING clause with four different bind variables:
EXECUTE IMMEDIATE sql_stmt USING a, a, b, a;
If the dynamic statement represents a PL/SQL block, the rules for duplicate placeholders are different. Each unique placeholder maps to a single item in the USING clause. If the same placeholder appears two or more times, all references to that name correspond to one bind argument in the USING clause. In Example 7-7, all references to the placeholder x are associated with the first bind argument a, and the second unique placeholder y is associated with the second bind argument b.
Example 7-7 Using Duplicate Placeholders With Dynamic SQL
CREATE PROCEDURE calc_stats(w NUMBER, x NUMBER, y NUMBER, z NUMBER) IS
BEGIN
  DBMS_OUTPUT.PUT_LINE(w + x + y + z);
END;
/
DECLARE
   a NUMBER := 4;
   b NUMBER := 7;
   plsql_block VARCHAR2(100);
BEGIN
   plsql_block := 'BEGIN calc_stats(:x, :x, :y, :x); END;';
   EXECUTE IMMEDIATE plsql_block USING a, b;
END;
/

Using Cursor Attributes with Dynamic SQL
The SQL cursor attributes %FOUND, %ISOPEN, %NOTFOUND, and %ROWCOUNT work when you issue an INSERT, UPDATE, DELETE, or single-row SELECT statement in dynamic SQL:
BEGIN
  EXECUTE IMMEDIATE 'DELETE FROM employees WHERE employee_id > 1000';
  DBMS_OUTPUT.PUT_LINE('Number of employees deleted: ' || TO_CHAR(SQL%ROWCOUNT));
END;
/

Likewise, when appended to a cursor variable name, the cursor attributes return information about the execution of a multi-row query:
Example 7-8 Accessing %ROWCOUNT For an Explicit Cursor
DECLARE
  TYPE cursor_ref IS REF CURSOR;
  c1 cursor_ref;
  TYPE emp_tab IS TABLE OF employees%ROWTYPE;
  rec_tab emp_tab;
  rows_fetched NUMBER;
BEGIN
  OPEN c1 FOR 'SELECT * FROM employees';
  FETCH c1 BULK COLLECT INTO rec_tab;
  rows_fetched := c1%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('Number of employees fetched: ' || TO_CHAR(rows_fetched));
END;
/

For more information about cursor attributes, see "Managing Cursors in PL/SQL".
Passing Nulls to Dynamic SQL
The literal NULL is not allowed in the USING clause. To work around this restriction, replace the keyword NULL with an uninitialized variable:
CREATE TABLE employees_temp AS SELECT * FROM EMPLOYEES;
DECLARE
   a_null CHAR(1); -- set to NULL automatically at run time
BEGIN
   EXECUTE IMMEDIATE 'UPDATE employees_temp SET commission_pct = :x' USING a_null;
END;
/

Using Database Links with Dynamic SQL
PL/SQL subprograms can execute dynamic SQL statements that use database links to refer to objects on remote databases:
CREATE PROCEDURE delete_dept (db_link VARCHAR2, dept_id INTEGER) IS
BEGIN
   EXECUTE IMMEDIATE 'DELETE FROM departments@' || db_link ||
      ' WHERE department_id = :num' USING dept_id;
END;
/
-- delete department id 41 in the departments table on the remote DB hr_db
CALL delete_dept('hr_db', 41); 

The targets of remote procedure calls (RPCs) can contain dynamic SQL statements. For example, suppose the following standalone function, which returns the number of rows in a table, resides on the hr_db database in London:
CREATE FUNCTION row_count (tab_name VARCHAR2) RETURN NUMBER AS
   rows NUMBER;
BEGIN
   EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || tab_name INTO rows;
   RETURN rows;
END;
/
-- From an anonymous block, you might call the function remotely, as follows:
DECLARE
   emp_count INTEGER;
BEGIN
   emp_count := row_count@hr_db('employees');
   DBMS_OUTPUT.PUT_LINE(emp_count);
END;
/

Using Invoker Rights with Dynamic SQL
Dynamic SQL lets you write schema-management procedures that can be centralized in one schema, and can be called from other schemas and operate on the objects in those schemas. For example, this procedure can drop any kind of database object:
CREATE OR REPLACE PROCEDURE drop_it (kind IN VARCHAR2, name IN VARCHAR2)
  AUTHID CURRENT_USER AS
BEGIN
   EXECUTE IMMEDIATE 'DROP ' || kind || ' ' || name;
END;
/

Let's say that this procedure is part of the HR schema. Without the AUTHID clause, the procedure would always drop objects in the HR schema, regardless of who calls it. Even if you pass a fully qualified object name, this procedure would not have the privileges to make changes in other schemas.
The AUTHID clause lifts both of these restrictions. It lets the procedure run with the privileges of the user that invokes it, and makes unqualified references refer to objects in that user's schema.
For details, see "Using Invoker's Rights Versus Definer's Rights (AUTHID Clause)".
Using Pragma RESTRICT_REFERENCES with Dynamic SQL
A function called from SQL statements must obey certain rules meant to control side effects. (See "Controlling Side Effects of PL/SQL Subprograms".) To check for violations of the rules, you can use the pragma RESTRICT_REFERENCES. The pragma asserts that a function does not read or write database tables or package variables. (For more information, See Oracle Database Application Developer's Guide - Fundamentals.)
If the function body contains a dynamic INSERT, UPDATE, or DELETE statement, the function always violates the rules write no database state (WNDS) and read no database state (RNDS). PL/SQL cannot detect those side-effects automatically, because dynamic SQL statements are checked at run time, not at compile time. In an EXECUTE IMMEDIATE statement, only the INTO clause can be checked at compile time for violations of RNDS.
Avoiding Deadlocks with Dynamic SQL
In a few situations, executing a SQL data definition statement results in a deadlock. For example, the following procedure causes a deadlock because it attempts to drop itself. To avoid deadlocks, never try to ALTER or DROP a subprogram or package while you are still using it.
CREATE OR REPLACE PROCEDURE calc_bonus (emp_id NUMBER) AS
BEGIN
   EXECUTE IMMEDIATE 'DROP PROCEDURE calc_bonus'; -- deadlock!
END;
/

Backward Compatibility of the USING Clause
When a dynamic INSERT, UPDATE, or DELETE statement has a RETURNING clause, output bind arguments can go in the RETURNING INTO clause or the USING clause. In new applications, use the RETURNING INTO clause. In old applications, you can continue to use the USING clause.
Using Dynamic SQL With PL/SQL Records and Collections
You can use dynamic SQL with records and collections. As shown in Example 7-9, you can fetch rows from the result set of a dynamic multi-row query into a record:
Example 7-9 Dynamic SQL Fetching into a Record
DECLARE
   TYPE EmpCurTyp IS REF CURSOR;
   emp_cv   EmpCurTyp;
   emp_rec  employees%ROWTYPE;
   sql_stmt VARCHAR2(200);
   v_job   VARCHAR2(10) := 'ST_CLERK';
BEGIN
   sql_stmt := 'SELECT * FROM employees WHERE job_id = :j';
   OPEN emp_cv FOR sql_stmt USING v_job;
   LOOP
     FETCH emp_cv INTO emp_rec;
     EXIT WHEN emp_cv%NOTFOUND;
     DBMS_OUTPUT.PUT_LINE('Name: ' || emp_rec.last_name || ' Job Id: ' ||
                           emp_rec.job_id);
   END LOOP;
   CLOSE emp_cv;
END;
/











Native Dynamic SQL
A happy and gracious flexibility ... --Matthew Arnold
This chapter shows you how to use native dynamic SQL (dynamic SQL for short), a PL/SQL interface that makes your applications more flexible and versatile. You learn simple ways to write programs that can build and process SQL statements "on the fly" at run time.
Within PL/SQL, you can execute any kind of SQL statement (even data definition and data control statements) without resorting to cumbersome programmatic approaches. Dynamic SQL blends seamlessly into your programs, making them more efficient, readable, and concise.
This chapter discusses the following topics:
What Is Dynamic SQL?
The Need for Dynamic SQL
Using the EXECUTE IMMEDIATE Statement
Using the OPEN-FOR, FETCH, and CLOSE Statements
Tips and Traps for Dynamic SQL
What Is Dynamic SQL?
Most PL/SQL programs do a specific, predictable job. For example, a stored procedure might accept an employee number and salary increase, then update the sal column in the emp table. In this case, the full text of the UPDATE statement is known at compile time. Such statements do not change from execution to execution. So, they are called static SQL statements.
However, some programs must build and process a variety of SQL statements at run time. For example, a general-purpose report writer must build different SELECT statements for the various reports it generates. In this case, the full text of the statement is unknown until run time. Such statements can, and probably will, change from execution to execution. So, they are called dynamic SQL statements.
Dynamic SQL statements are stored in character strings built by your program at run time. Such strings must contain the text of a valid SQL statement or PL/SQL block. They can also contain placeholders for bind arguments. A placeholder is an undeclared identifier, so its name, to which you must prefix a colon, does not matter. For example, PL/SQL makes no distinction between the following strings:
'DELETE FROM emp WHERE sal > :my_sal AND comm < :my_comm'
'DELETE FROM emp WHERE sal > :s AND comm < :c'

To process most dynamic SQL statements, you use the EXECUTE IMMEDIATE statement. However, to process a multi-row query (SELECT statement), you must use the OPEN-FOR, FETCH, and CLOSE statements.
The Need for Dynamic SQL
You need dynamic SQL in the following situations:
•	You want to execute a SQL data definition statement (such as CREATE), a data control statement (such as GRANT), or a session control statement (such as ALTER SESSION). In PL/SQL, such statements cannot be executed statically.
•	You want more flexibility. For example, you might want to defer your choice of schema objects until run time. Or, you might want your program to build different search conditions for the WHERE clause of a SELECT statement. A more complex program might choose from various SQL operations, clauses, etc.
•	You use package DBMS_SQL to execute SQL statements dynamically, but you want better performance, something easier to use, or functionality that DBMS_SQL lacks such as support for objects and collections. (For a comparison with DBMS_SQL, see Oracle9i Application Developer's Guide - Fundamentals.)
Using the EXECUTE IMMEDIATE Statement
The EXECUTE IMMEDIATE statement prepares (parses) and immediately executes a dynamic SQL statement or an anonymous PL/SQL block. The syntax is
EXECUTE IMMEDIATE dynamic_string
[INTO {define_variable[, define_variable]... | record}]
[USING [IN | OUT | IN OUT] bind_argument
    [, [IN | OUT | IN OUT] bind_argument]...]
[{RETURNING | RETURN} INTO bind_argument[, bind_argument]...];

where dynamic_string is a string expression that represents a SQL statement or PL/SQL block, define_variable is a variable that stores a selected column value, and record is a user-defined or %ROWTYPE record that stores a selected row. An input bind_argument is an expression whose value is passed to the dynamic SQL statement or PL/SQL block. An output bind_argument is a variable that stores a value returned by the dynamic SQL statement or PL/SQL block.
Except for multi-row queries, the dynamic string can contain any SQL statement (without the terminator) or any PL/SQL block (with the terminator). The string can also contain placeholders for bind arguments. However, you cannot use bind arguments to pass the names of schema objects to a dynamic SQL statement. For the right way, see "Making Procedures Work on Arbitrarily Named Schema Objects".
Used only for single-row queries, the INTO clause specifies the variables or record into which column values are retrieved. For each value retrieved by the query, there must be a corresponding, type-compatible variable or field in the INTO clause.
Used only for DML statements that have a RETURNING clause (without a BULK COLLECT clause), the RETURNING INTO clause specifies the variables into which column values are returned. For each value returned by the DML statement, there must be a corresponding, type-compatible variable in the RETURNING INTO clause.
You can place all bind arguments in the USING clause. The default parameter mode is IN. For DML statements that have a RETURNING clause, you can place OUT arguments in the RETURNING INTO clause without specifying the parameter mode, which, by definition, is OUT. If you use both the USING clause and the RETURNING INTO clause, the USING clause can contain only IN arguments.
At run time, bind arguments replace corresponding placeholders in the dynamic string. So, every placeholder must be associated with a bind argument in the USING clause and/or RETURNING INTO clause. You can use numeric, character, and string literals as bind arguments, but you cannot use Boolean literals (TRUE, FALSE, and NULL). To pass nulls to the dynamic string, you must use a workaround. See "Passing Nulls".
Dynamic SQL supports all the SQL datatypes. So, for example, define variables and bind arguments can be collections, LOBs, instances of an object type, and refs. As a rule, dynamic SQL does not support PL/SQL-specific types. So, for example, define variables and bind arguments cannot be Booleans or index-by tables. The only exception is that a PL/SQL record can appear in the INTO clause.
You can execute a dynamic SQL statement repeatedly using new values for the bind arguments. However, you incur some overhead because EXECUTE IMMEDIATE re-prepares the dynamic string before every execution.
Some Examples of Dynamic SQL
The following PL/SQL block contains several examples of dynamic SQL:
DECLARE
   sql_stmt    VARCHAR2(200);
   plsql_block VARCHAR2(500);
   emp_id      NUMBER(4) := 7566;
   salary      NUMBER(7,2);
   dept_id     NUMBER(2) := 50;
   dept_name   VARCHAR2(14) := 'PERSONNEL';
   location    VARCHAR2(13) := 'DALLAS';
   emp_rec     emp%ROWTYPE;
BEGIN
   EXECUTE IMMEDIATE 'CREATE TABLE bonus (id NUMBER, amt NUMBER)';
   sql_stmt := 'INSERT INTO dept VALUES (:1, :2, :3)';
   EXECUTE IMMEDIATE sql_stmt USING dept_id, dept_name, location;
   sql_stmt := 'SELECT * FROM emp WHERE empno = :id';
   EXECUTE IMMEDIATE sql_stmt INTO emp_rec USING emp_id;
   plsql_block := 'BEGIN emp_pkg.raise_salary(:id, :amt); END;';
   EXECUTE IMMEDIATE plsql_block USING 7788, 500;
   sql_stmt := 'UPDATE emp SET sal = 2000 WHERE empno = :1
      RETURNING sal INTO :2';
   EXECUTE IMMEDIATE sql_stmt USING emp_id RETURNING INTO salary;
   EXECUTE IMMEDIATE 'DELETE FROM dept WHERE deptno = :num'
      USING dept_id;
   EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE TRUE';
END;

In the example below, a standalone procedure accepts the name of a database table (such as 'emp') and an optional WHERE-clause condition (such as 'sal > 2000'). If you omit the condition, the procedure deletes all rows from the table. Otherwise, the procedure deletes only those rows that meet the condition.
CREATE PROCEDURE delete_rows (
   table_name IN VARCHAR2,
   condition IN VARCHAR2 DEFAULT NULL) AS
   where_clause VARCHAR2(100) := ' WHERE ' || condition;
BEGIN
   IF condition IS NULL THEN where_clause := NULL; END IF;
   EXECUTE IMMEDIATE 'DELETE FROM ' || table_name || where_clause;
EXCEPTION
   ...
END;
Backward Compatibility of the USING Clause
When a dynamic INSERT, UPDATE, or DELETE statement has a RETURNING clause, output bind arguments can go in the RETURNING INTO clause or the USING clause. In new applications, use the RETURNING INTO clause. In old applications, you can continue to use the USING clause. For example, both of the following EXECUTE IMMEDIATE statements are allowed:
DECLARE
   sql_stmt VARCHAR2(200);
   my_empno NUMBER(4) := 7902;
   my_ename VARCHAR2(10);
   my_job   VARCHAR2(9);
   my_sal   NUMBER(7,2) := 3250.00;
BEGIN
   sql_stmt := 'UPDATE emp SET sal = :1 WHERE empno = :2
      RETURNING ename, job INTO :3, :4';

   /* Bind returned values through USING clause. */
   EXECUTE IMMEDIATE sql_stmt
      USING my_sal, my_empno, OUT my_ename, OUT my_job;

   /* Bind returned values through RETURNING INTO clause. */
   EXECUTE IMMEDIATE sql_stmt
      USING my_sal, my_empno RETURNING INTO my_ename, my_job;
   ...
END;
Specifying Parameter Modes
With the USING clause, you need not specify a parameter mode for input bind arguments because the mode defaults to IN. With the RETURNING INTO clause, you cannot specify a parameter mode for output bind arguments because, by definition, the mode is OUT. An example follows:
DECLARE
   sql_stmt VARCHAR2(200);
   dept_id  NUMBER(2) := 30;
   old_loc  VARCHAR2(13);
BEGIN
   sql_stmt := 
      'DELETE FROM dept WHERE deptno = :1 RETURNING loc INTO :2';
   EXECUTE IMMEDIATE sql_stmt USING dept_id RETURNING INTO old_loc;
   ...
END;

When appropriate, you must specify the OUT or IN OUT mode for bind arguments passed as parameters. For example, suppose you want to call the following standalone procedure:
CREATE PROCEDURE create_dept (
   deptno IN OUT NUMBER,
   dname  IN VARCHAR2,
   loc    IN VARCHAR2) AS
BEGIN
   SELECT deptno_seq.NEXTVAL INTO deptno FROM dual;
   INSERT INTO dept VALUES (deptno, dname, loc);
END;

To call the procedure from a dynamic PL/SQL block, you must specify the IN OUT mode for the bind argument associated with formal parameter deptno, as follows:
DECLARE
   plsql_block VARCHAR2(500);
   new_deptno NUMBER(2);
   new_dname  VARCHAR2(14) := 'ADVERTISING';
   new_loc    VARCHAR2(13) := 'NEW YORK';
BEGIN
   plsql_block := 'BEGIN create_dept(:a, :b, :c); END;';
   EXECUTE IMMEDIATE plsql_block
      USING IN OUT new_deptno, new_dname, new_loc;
   IF new_deptno > 90 THEN ...
END;
Using the OPEN-FOR, FETCH, and CLOSE Statements
You use three statements to process a dynamic multi-row query: OPEN-FOR, FETCH, and CLOSE. First, you OPEN a cursor variable FOR a multi-row query. Then, you FETCH rows from the result set one at a time. When all the rows are processed, you CLOSE the cursor variable. (For more information about cursor variables, see "Using Cursor Variables".)
Opening the Cursor Variable
The OPEN-FOR statement associates a cursor variable with a multi-row query, executes the query, identifies the result set, positions the cursor on the first row in the result set, then zeroes the rows-processed count kept by %ROWCOUNT.
Unlike the static form of OPEN-FOR, the dynamic form has an optional USING clause. At run time, bind arguments in the USING clause replace corresponding placeholders in the dynamic SELECT statement. The syntax is
OPEN {cursor_variable | :host_cursor_variable} FOR dynamic_string
   [USING bind_argument[, bind_argument]...];

where cursor_variable is a weakly typed cursor variable (one without a return type), host_cursor_variable is a cursor variable declared in a PL/SQL host environment such as an OCI program, and dynamic_string is a string expression that represents a multi-row query.
In the following example, you declare a cursor variable, then associate it with a dynamic SELECT statement that returns rows from the emp table:
DECLARE
   TYPE EmpCurTyp IS REF CURSOR;  -- define weak REF CURSOR type
   emp_cv   EmpCurTyp;  -- declare cursor variable
   my_ename VARCHAR2(15);
   my_sal   NUMBER := 1000;
BEGIN
   OPEN emp_cv FOR  -- open cursor variable
      'SELECT ename, sal FROM emp WHERE sal > :s' USING my_sal;
   ...
END;

Any bind arguments in the query are evaluated only when the cursor variable is opened. So, to fetch from the cursor using different bind values, you must reopen the cursor variable with the bind arguments set to their new values.
Fetching from the Cursor Variable
The FETCH statement returns a row from the result set of a multi-row query, assigns the values of select-list items to corresponding variables or fields in the INTO clause, increments the count kept by %ROWCOUNT, and advances the cursor to the next row. The syntax follows:
FETCH {cursor_variable | :host_cursor_variable}
   INTO {define_variable[, define_variable]... | record};

Continuing the example, you fetch rows from cursor variable emp_cv into define variables my_ename and my_sal:
LOOP
   FETCH emp_cv INTO my_ename, my_sal;  -- fetch next row
   EXIT WHEN emp_cv%NOTFOUND;  -- exit loop when last row is fetched
   -- process row
END LOOP;

For each column value returned by the query associated with the cursor variable, there must be a corresponding, type-compatible variable or field in the INTO clause. You can use a different INTO clause on separate fetches with the same cursor variable. Each fetch retrieves another row from the same result set.
If you try to fetch from a closed or never-opened cursor variable, PL/SQL raises the predefined exception INVALID_CURSOR.
Closing the Cursor Variable
The CLOSE statement disables a cursor variable. After that, the associated result set is undefined. The syntax follows:
CLOSE {cursor_variable | :host_cursor_variable};

In this example, when the last row is processed, you close cursor variable emp_cv:
LOOP
   FETCH emp_cv INTO my_ename, my_sal;
   EXIT WHEN emp_cv%NOTFOUND;
   -- process row
END LOOP;
CLOSE emp_cv;  -- close cursor variable

If you try to close an already-closed or never-opened cursor variable, PL/SQL raises INVALID_CURSOR.
Examples of Dynamic SQL for Records, Objects, and Collections
As the following example shows, you can fetch rows from the result set of a dynamic multi-row query into a record:
DECLARE
   TYPE EmpCurTyp IS REF CURSOR;
   emp_cv   EmpCurTyp;
   emp_rec  emp%ROWTYPE;
   sql_stmt VARCHAR2(200);
   my_job   VARCHAR2(15) := 'CLERK';
BEGIN
   sql_stmt := 'SELECT * FROM emp WHERE job = :j';
   OPEN emp_cv FOR sql_stmt USING my_job;
   LOOP
      FETCH emp_cv INTO emp_rec;
      EXIT WHEN emp_cv%NOTFOUND;
      -- process record
   END LOOP;
   CLOSE emp_cv;
END;

The next example illustrates the use of objects and collections. Suppose you define object type Person and VARRAY type Hobbies, as follows:
CREATE TYPE Person AS OBJECT (name VARCHAR2(25), age NUMBER);
CREATE TYPE Hobbies IS VARRAY(10) OF VARCHAR2(25);

Now, using dynamic SQL, you can write a package of procedures that uses these types, as follows:
CREATE PACKAGE teams AS
   PROCEDURE create_table (tab_name VARCHAR2);
   PROCEDURE insert_row (tab_name VARCHAR2, p Person, h Hobbies);
   PROCEDURE print_table (tab_name VARCHAR2);
END;

CREATE PACKAGE BODY teams AS
   PROCEDURE create_table (tab_name VARCHAR2) IS
   BEGIN
      EXECUTE IMMEDIATE 'CREATE TABLE ' || tab_name || 
         ' (pers Person, hobbs Hobbies)';
   END;

   PROCEDURE insert_row (
      tab_name VARCHAR2,
      p Person,
      h Hobbies) IS
   BEGIN
      EXECUTE IMMEDIATE 'INSERT INTO ' || tab_name || 
         ' VALUES (:1, :2)' USING p, h;
   END;

   PROCEDURE print_table (tab_name VARCHAR2) IS
      TYPE RefCurTyp IS REF CURSOR;
      cv RefCurTyp;
      p  Person;
      h  Hobbies;
   BEGIN
      OPEN cv FOR 'SELECT pers, hobbs FROM ' || tab_name;
      LOOP
         FETCH cv INTO p, h;
         EXIT WHEN cv%NOTFOUND;
         -- print attributes of 'p' and elements of 'h'
      END LOOP;
      CLOSE cv;
   END;
END;

From an anonymous PL/SQL block, you might call the procedures in package teams, as follows:
DECLARE
   team_name VARCHAR2(15);
   ...
BEGIN
   ...
   team_name := 'Notables';
   teams.create_table(team_name);
   teams.insert_row(team_name, Person('John', 31), 
      Hobbies('skiing', 'coin collecting', 'tennis'));
   teams.insert_row(team_name, Person('Mary', 28), 
      Hobbies('golf', 'quilting', 'rock climbing'));
   teams.print_table(team_name);
END;
Using Bulk Dynamic SQL
In this section, you learn how to add the power of bulk binding to dynamic SQL. Bulk binding improves performance by minimizing the number of context switches between the PL/SQL and SQL engines. With bulk binding, entire collections, not just individual elements, are passed back and forth.
Using the following commands, clauses, and cursor attribute, your applications can construct bulk SQL statements, then execute them dynamically at run time:
BULK FETCH statement
BULK EXECUTE IMMEDIATE statement
FORALL statement
COLLECT INTO clause
RETURNING INTO clause
%BULK_ROWCOUNT cursor attribute
The static versions of these statements, clauses, and cursor attribute are discussed in "Reducing Loop Overhead for Collections with Bulk Binds". Refer to that section for background information.
Syntax for Dynamic Bulk Binds
Bulk binding lets Oracle bind a variable in a SQL statement to a collection of values. The collection type can be any PL/SQL collection type (index-by table, nested table, or varray). However, the collection elements must have a SQL datatype such as CHAR, DATE, or NUMBER. Three statements support dynamic bulk binds: EXECUTE IMMEDIATE, FETCH, and FORALL.
Bulk EXECUTE IMMEDIATE
This statement lets you bulk-bind define variables or OUT bind arguments passed as parameters to a dynamic SQL statement. The syntax follows:
EXECUTE IMMEDIATE dynamic_string
   [[BULK COLLECT] INTO define_variable[, define_variable ...]]
   [USING bind_argument[, bind_argument ...]]
   [{RETURNING | RETURN} 
   BULK COLLECT INTO bind_argument[, bind_argument ...]];

With a dynamic multi-row query, you can use the BULK COLLECT INTO clause to bind define variables. The values in each column are stored in a collection.
With a dynamic INSERT, UPDATE, or DELETE statement that returns multiple rows, you can use the RETURNING BULK COLLECT INTO clause to bulk-bind output variables. The returned rows of values are stored in a set of collections.
Bulk FETCH
This statement lets you fetch from a dynamic cursor the same way you fetch from a static cursor. The syntax follows:
FETCH dynamic_cursor 
   BULK COLLECT INTO define_variable[, define_variable ...];

If the number of define variables in the BULK COLLECT INTO list exceeds the number of columns in the query select-list, Oracle generates an error.
Bulk FORALL
This statement lets you bulk-bind input variables in a dynamic SQL statement. In addition, you can use the EXECUTE IMMEDIATE statement inside a FORALL loop. The syntax follows:
FORALL index IN lower bound..upper bound
   EXECUTE IMMEDIATE dynamic_string
   USING bind_argument | bind_argument(index)
      [, bind_argument | bind_argument(index)] ...
   [{RETURNING | RETURN} BULK COLLECT 
      INTO bind_argument[, bind_argument ... ]];

The dynamic string must represent an INSERT, UPDATE, or DELETE statement (not a SELECT statement).
Examples of Dynamic Bulk Binds
You can bind define variables in a dynamic query using the BULK COLLECT INTO clause. As the following example shows, you can use that clause in a bulk FETCH or bulk EXECUTE IMMEDIATE statement:
DECLARE
   TYPE EmpCurTyp IS REF CURSOR;
   TYPE NumList IS TABLE OF NUMBER;
   TYPE NameList IS TABLE OF VARCHAR2(15);
   emp_cv EmpCurTyp;
   empnos NumList;
   enames NameList;
   sals   NumList;
BEGIN
   OPEN emp_cv FOR 'SELECT empno, ename FROM emp';
   FETCH emp_cv BULK COLLECT INTO empnos, enames;
   CLOSE emp_cv;

   EXECUTE IMMEDIATE 'SELECT sal FROM emp'
      BULK COLLECT INTO sals;
END;

Only the INSERT, UPDATE, and DELETE statements can have output bind variables. To bulk-bind them, you use the BULK RETURNING INTO clause, which can appear only in an EXECUTE IMMEDIATE. An example follows:
DECLARE
   TYPE NameList IS TABLE OF VARCHAR2(15);
   enames    NameList;
   bonus_amt NUMBER := 500;
   sql_stmt  VARCHAR(200);
BEGIN
   sql_stmt := 'UPDATE emp SET bonus = :1 RETURNING ename INTO :2';
   EXECUTE IMMEDIATE sql_stmt
      USING bonus_amt RETURNING BULK COLLECT INTO enames;
END;

To bind the input variables in a SQL statement, you can use the FORALL statement and USING clause, as shown below. However, the SQL statement cannot be a query.
DECLARE
   TYPE NumList IS TABLE OF NUMBER;
   TYPE NameList IS TABLE OF VARCHAR2(15);
   empnos NumList;
   enames NameList;
BEGIN
   empnos := NumList(1,2,3,4,5);
   FORALL i IN 1..5
      EXECUTE IMMEDIATE
        'UPDATE emp SET sal = sal * 1.1 WHERE empno = :1
         RETURNING ename INTO :2'
         USING empnos(i) RETURNING BULK COLLECT INTO enames;
   ...
END;
Tips and Traps for Dynamic SQL
This section shows you how to take full advantage of dynamic SQL and how to avoid some common pitfalls.
Improving Performance
In the example below, Oracle opens a different cursor for each distinct value of emp_id. This can lead to resource contention and poor performance.
CREATE PROCEDURE fire_employee (emp_id NUMBER) AS
BEGIN
   EXECUTE IMMEDIATE
      'DELETE FROM emp WHERE empno = ' || TO_CHAR(emp_id);
END;

You can improve performance by using a bind variable, as shown below. This allows Oracle to reuse the same cursor for different values of emp_id.
CREATE PROCEDURE fire_employee (emp_id NUMBER) AS
BEGIN
   EXECUTE IMMEDIATE
      'DELETE FROM emp WHERE empno = :num' USING emp_id;
END;
Making Procedures Work on Arbitrarily Named Schema Objects
Suppose you need a procedure that accepts the name of any database table, then drops that table from your schema. Using dynamic SQL, you might write the following standalone procedure:
CREATE PROCEDURE drop_table (table_name IN VARCHAR2) AS
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE :tab' USING table_name;
END;

However, at run time, this procedure fails with an invalid table name error. That is because you cannot use bind arguments to pass the names of schema objects to a dynamic SQL statement. Instead, you must embed parameters in the dynamic string, then pass the names of schema objects to those parameters.
To debug the last example, you must revise the EXECUTE IMMEDIATE statement. Instead of using a placeholder and bind argument, you embed parameter table_name in the dynamic string, as follows:
CREATE PROCEDURE drop_table (table_name IN VARCHAR2) AS
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE ' || table_name;
END;

Now, you can pass the name of any database table to the dynamic SQL statement.
Using Duplicate Placeholders
Placeholders in a dynamic SQL statement are associated with bind arguments in the USING clause by position, not by name. So, if the same placeholder appears two or more times in the SQL statement, each appearance must correspond to a bind argument in the USING clause. For example, given the dynamic string
sql_stmt := 'INSERT INTO payroll VALUES (:x, :x, :y, :x)';

you might code the corresponding USING clause as follows:
EXECUTE IMMEDIATE sql_stmt USING a, a, b, a;

However, only the unique placeholders in a dynamic PL/SQL block are associated with bind arguments in the USING clause by position. So, if the same placeholder appears two or more times in a PL/SQL block, all appearances correspond to one bind argument in the USING clause. In the example below, the first unique placeholder (x) is associated with the first bind argument (a). Likewise, the second unique placeholder (y) is associated with the second bind argument (b).
DECLARE
   a NUMBER := 4;
   b NUMBER := 7;
BEGIN
   plsql_block := 'BEGIN calc_stats(:x, :x, :y, :x); END;'
   EXECUTE IMMEDIATE plsql_block USING a, b;
   ...
END;
Using Cursor Attributes
Every explicit cursor has four attributes: %FOUND, %ISOPEN, %NOTFOUND, and %ROWCOUNT. When appended to the cursor name, they return useful information about the execution of static and dynamic SQL statements.
To process SQL data manipulation statements, Oracle opens an implicit cursor named SQL. Its attributes return information about the most recently executed INSERT, UPDATE, DELETE, or single-row SELECT statement. For example, the following standalone function uses %ROWCOUNT to return the number of rows deleted from a database table:
CREATE FUNCTION rows_deleted (
   table_name IN VARCHAR2, 
   condition IN VARCHAR2) RETURN INTEGER AS
BEGIN
   EXECUTE IMMEDIATE 
      'DELETE FROM ' || table_name || ' WHERE ' || condition;
   RETURN SQL%ROWCOUNT;  -- return number of rows deleted
END;

Likewise, when appended to a cursor variable name, the cursor attributes return information about the execution of a multi-row query. For more information about cursor attributes, see "Using Cursor Attributes".
Passing Nulls
Suppose you want to pass nulls to a dynamic SQL statement. For example, you might write the following EXECUTE IMMEDIATE statement:
EXECUTE IMMEDIATE 'UPDATE emp SET comm = :x' USING NULL;

However, this statement fails with a bad expression error because the literal NULL is not allowed in the USING clause. To work around this restriction, simply replace the keyword NULL with an uninitialized variable, as follows:
DECLARE
   a_null CHAR(1); -- set to NULL automatically at run time
BEGIN
   EXECUTE IMMEDIATE 'UPDATE emp SET comm = :x' USING a_null;
END;
Doing Remote Operations
As the following example shows, PL/SQL subprograms can execute dynamic SQL statements that refer to objects on a remote database:
PROCEDURE delete_dept (db_link VARCHAR2, dept_id INTEGER) IS
BEGIN
   EXECUTE IMMEDIATE 'DELETE FROM dept@' || db_link ||
      ' WHERE deptno = :num' USING dept_id;
END;

Also, the targets of remote procedure calls (RPCs) can contain dynamic SQL statements. For example, suppose the following standalone function, which returns the number of rows in a table, resides on the Chicago database:
CREATE FUNCTION row_count (tab_name VARCHAR2) RETURN INTEGER AS
   rows INTEGER;
BEGIN
   EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || tab_name INTO rows;
   RETURN rows;
END;

From an anonymous block, you might call the function remotely, as follows:
DECLARE
   emp_count INTEGER;
BEGIN
   emp_count := row_count@chicago('emp');
Using Invoker Rights
By default, a stored procedure executes with the privileges of its definer, not its invoker. Such procedures are bound to the schema in which they reside. For example, assume that the following standalone procedure, which can drop any kind of database object, resides in schema scott:
CREATE PROCEDURE drop_it (kind IN VARCHAR2, name IN VARCHAR2) AS
BEGIN
   EXECUTE IMMEDIATE 'DROP ' || kind || ' ' || name;
END;

Also assume that user jones has been granted the EXECUTE privilege on this procedure. When user jones calls drop_it, as follows, the dynamic DROP statement executes with the privileges of user scott:
SQL> CALL drop_it('TABLE', 'dept');

Also, the unqualified reference to table dept is resolved in schema scott. So, the procedure drops the table from schema scott, not from schema jones.
However, the AUTHID clause enables a stored procedure to execute with the privileges of its invoker (current user). Such procedures are not bound to a particular schema. For example, the following version of drop_it executes with the privileges of its invoker:
CREATE PROCEDURE drop_it (kind IN VARCHAR2, name IN VARCHAR2)
   AUTHID CURRENT_USER AS
BEGIN
   EXECUTE IMMEDIATE 'DROP ' || kind || ' ' || name;
END;

Also, the unqualified reference to the database object is resolved in the schema of the invoker. For details, see "Invoker Rights Versus Definer Rights".
Using Pragma RESTRICT_REFERENCES
A function called from SQL statements must obey certain rules meant to control side effects. (See "Controlling Side Effects of PL/SQL Subprograms".) To check for violations of the rules, you can use the pragma RESTRICT_REFERENCES. The pragma asserts that a function does not read and/or write database tables and/or package variables. (For more information, See Oracle9i Application Developer's Guide - Fundamentals.)
However, if the function body contains a dynamic INSERT, UPDATE, or DELETE statement, the function always violates the rules "write no database state" (WNDS) and "read no database state" (RNDS). That is because dynamic SQL statements are checked at run time, not at compile time. In an EXECUTE IMMEDIATE statement, only the INTO clause can be checked at compile time for violations of RNDS.
Avoiding Deadlocks
In a few situations, executing a SQL data definition statement results in a deadlock. For example, the procedure below causes a deadlock because it attempts to drop itself. To avoid deadlocks, never try to ALTER or DROP a subprogram or package while you are still using it.
CREATE PROCEDURE calc_bonus (emp_id NUMBER) AS
BEGIN
   ...
   EXECUTE IMMEDIATE 'DROP PROCEDURE calc_bonus';

