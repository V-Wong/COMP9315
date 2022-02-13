# PostgreSQL Overview
## PostgreSQL Functionality

|Entity|Description|
|----|----|
|Users|Who can use the system, what they can do.|
|Groups|Groups of users, for role-based privileges.|
|Databases|Collections of schemas/tables/views/...|
|Namespaces|To uniquely identify objects.|
|Tables|Collection of tuples.|
|Views|"Virtual" tables|
|Functions|Operations on values from/in tables.|
|Triggers|Operations invoked in response to events.|
|Operators|Functions with infix syntax.|
|Aggregates|Operations over whole table columns.|
|Types|User-defined data types (with own operations).|
|Rules|For query rewriting.|
|Access methods|Efficient access to tuples in tables.|

### Implementation of SQL
PostgreSQL's dialect of SQL is mostly standard (but with extensions).

Differences visible at the user-level:
- Attributes containing arrays of atomic values.
- Table type inheritance, table-valued functions.

Differences at the implementation level:
- Referential integrity checking is accomplished via triggers.
- Views are implemented via query re-writing rules.

Example:
```sql
create view myview as select * from mytab;
// is implemented as
create type as myview (same fields as mytab);
create rule myview as on select to myview
            do instead select * from mytab;
```

### Stored Procedures
PostgreSQL stored procedures differ from SQL standard:
- Only provides functions, not procedures (but functions can return void).
- Allows function overloading.
- Defined at different "lexical level" to SQL.
- Provides own PL/SQL-like language for functions.

### Concurrency Handling
Concurrency is handled via **multi-version concurrency control** (MVCC).
- **Multiple "versions"** of the database exist together.
- A transaction sees the version that was valid at its **start-time**.
- Readers don't block writers; writers don't block readers.
- Significantly reduces need for locking.

Disadvantages of this approach:
- **Extra storage** for old versions of tuples.

Transactions can specify a **consistency level** for concurrency:
- **Read-committed** (allows some inconsistency), **serializable** (no inconsistency).
- Default isolation level is read-committed.

**Explicit locking** is also available:
- Different varieties: share/exclusive, row/table.
- Deadlock detection via time-out.

Access methods need to implement their own concurrency control.

### Open Extensibility Model
PostgreSQL has a well-defined and **open extensibility model**:
- Stored procedures are held in database as strings:
    - Allows a variety of languages to be used.
    - Language interpreters can be integrated into PostgreSQL engine.
- New data types, operators, aggregates, indexes can be added:
    - Typically requires code written in C, following defined API.
    - For new data types, need to write input/output functions.
    - For new indexes, need to implement file structures.

## PostgreSQL Architecture
### Client/Server Architecture
![](https://www.cse.unsw.edu.au/~cs9315/22T1/notes/A/Pics/intro/proc-arch-small.png)

Notes:
- Exactly one **postmaster** (postgres daemon/listener); many clients; many servers.
- **Each client** has its own **server process**.
- Client/server communication via TCP/IP or Unix sockets.
- Uses PostgreSQL-specific frontend/backend protocol.
- Client/server separation good for security/reliability.
- Client/server connection overhead is significant
    - Generally solved by **client-side pooling** of persistent connections.

### Memory/Storage Architecture
![](https://www.cse.unsw.edu.au/~cs9315/22T1/notes/A/Pics/intro/mem-arch-small.png)

Notes:
- All servers access database files via **buffer pool**. 
    - Thus all servers get a consistent view of data.
- Unix kernel provides additional buffering.
- Use of shared memory limits distribution/scalability.
    - All server processes must run on the same machine.
- Shared tables are "global" system catalogue tables.
    - Hold user/group/database info for entire PostgreSQL installation.

### File System Architecture
![](https://www.cse.unsw.edu.au/~cs9315/22T1/notes/A/Pics/intro/file-arch-small.png)

## Lifecycle of a PostgreSQL query
![](https://www.cse.unsw.edu.au/~cs9315/22T1/notes/A/Pics/intro/pg-processes-small.png)

How a PostgreSQL query is executed:
1. SQL query string is produced in client.
2. Client establishes connection to PostgreSQL.
3. Dedicated server process attached to client.
4. SQL query string sent to server process.
5. Server parses/plans/optimises query.
6. Server executes query to produce result tuples.
7. Tuples are transmitted back to client.
8. Client disconnected from server.