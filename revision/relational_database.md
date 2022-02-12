# Relational Database Revision
## Relational Databases
Relational databases are built on **relational theory**.
- Data is modelled as **relations** (tables) and **tuples** (rows).
- **Constraints** define **consistency** of data.
- **Normalisation** theory **validates** data designs.
- **Relational algebra** describes **manipulation** of data.

## Database Management Systems
### DBMS Functionality
DBMSs provide a variety of functionalities:
- **Storing/modifying** data and meta-data.
- **Constraint** definition/storage/maintenance/checking.
- **Declarative manipulation** of data (via SQL).
- **Extensibility** via views, triggers, procedures.
- **Query re-writing** (rules), **optimisation** (indexes).
- **Transaction** processing, **concurrency/recovery**.
- Etc.

Common feature of all relational DBMSs: relational model, SQL.

#### DBMS for Data Definition
Critical function of DBMS: **defining relational data** (DDL sub-language). This includes: 
- Relations (tables).
- Tuples (rows).
- Values.
- Types.
- Constraints.

Example:

```sql
create domain WAMvalue float
    check (value between 0.0 and 100.0);

create table Students (
    id integer,
    familyName text,
    givenName text,
    birthDate date,
    wam WAMvalue,
    primary key (id)
);
```

Executing the above adds **meta-data** to the database. DBMSs typically store meta-data as special tables (**catalogue**).

Specifying **constraints** is an important aspect of data definition:
- **Attribute** (column) constraints.
- **Tuple** (row) constraints.
- **Relation** (table) constraints.
- **Referential integrity** constraints.

Example:
```sql
create table Employee (
    id integer primary key, // relation constraint
    name varchar(40),
    salary real,
    age integer check (age > 15), // attribute constraint
    worksIn integer references Department(id), // referential constraint
    constraint PayOk check (salary > age * 1000) // tuple constraint
);
```

#### DBMS for Data Modification
Critical function of DBMS: **manipulating data** (DML sub-language). This includes:
- ``insert`` new tuples into tables.
- ``delete`` existing tuples from tables.
- ``update`` values within existing tuples.

Example:
```sql
insert into Enrolments(student, course, mark)
values (1234, 9315, 99);

update Enrolments set mark = 77
where student = 1234 and course = 9315;

delete Enrolments where student = 1234;
```

#### DBMS as Query Evaluator
Most common function of relational DBMSs
- Read an SQL query
- Return a table giving result of query

Example:
```sql
select 
    s.id, 
    c.code,
    e.mark
from
    Students s
join
    Enrollments e on s.id = e.student
join
    Courses c on e.course = c.id;
```

### DBMS Architecture
![](https://www.cse.unsw.edu.au/~cs9315/22T1/notes/A/Pics/intro/qryeval1-small.png)

Fundamental tenets of DBMS architecture:
- Data is stored **permanently** on **large slow devices**.
- Data is **processed** in **small fast memory**.

Implications:
- Data structures should **minimise storage utilisation**.
- Algorithms should **minimise memory-disk data transfers**.

#### Complications of DBMS Design

|Problem|Implication|
|----|----|
|Potentially **multiple concurrent accesses** to data structures (data tables, indexes, buffers, catalogues, ...).| Locking helps, but may degrade performance. Need concurrency-tolerant data structures.|
|**Transactional** requirements (atomicity, rollback, ...).|Require some form of logging.|
|Requirement for **high reliability** of raw data (recovery)|Require some form of logging.|

#### Components of DBMS Architecture

|Component|Description|
|----|----|
|Query Optimiser|Translates queries into efficient sequence of relational operations.|
|Query Executor|Controls execution of sequence of relational operations.|
|Access methods|Basis for implementation of relational operations.|
|Buffer manager|Manages data transfer between disk and main memory.|
|Storage manager|Manages allocation of disk space and data structures.|
|Concurrency manager|Controls concurrent access to database.|
|Recovery manager|Ensures consistent database state after system failures.|
|Integrity manager|Verifies integrity constraints and user privileges.|

### Database Engine Operations
DB engine = "relational algebra virtual machine". For each relational algebra operation:
- Various data structures and algorithms are available.
- DBMSs may provide only one, or may provide a choice.

Different implementations of Selection:
- Hash-structured file good for queries like:
    ```sql
    select * from Students where id = 1234;
    ```
- B-tree file good for queries like:
    ```sql
    select * from Employees where age > 55 
    ```

