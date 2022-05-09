# Query Execution
## Overview
A query execution plan:
- Consists of a **collection of RelOps**.
- Executing together to produce a set of result tuples.

Results may be passed from one operator to the next:
- **Materialization:** writing results to disk and reading them back.
- **Pipelining:** generating and passing via memory buffers.

## Materialisation
Steps in **materialisation** between two operators:
- First operator reads input(s) and **writes results to disk**.
- Next operator treats **tuples on disk as its input**.
- In essence, the **temporary tables are produced as real tables**.

**Advantage:**
- Intermediate results can be placed in a file structure (which can be chosen to **speed up execution of subsequent operators**).

**Disadvantage:**
- Requires disk space and read/write for intermediate results.

## Pipelining
How **pipelining** is organised between two operators:
- Operators execute "concurrently" as **producer/consumer pairs**.
- Structured as interacting iterators (``open; while(next); close``).

**Advantage:**
- No requirement for disk access (results passed **via memory buffers**).

**Disadvantages:**
- Higher-level operators access inputs **via linear scan**, or
- Requires sufficient memory buffers to hold all outputs.

### Pipelining Example
```sql
select s.id, e.course, e.mark
from   Student s, Enrolment e
where  e.student = s.id and
       e.semester = '05s2' and s.name = 'John';
```

Evaluated via communication between RA tree nodes:
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/qry-execution/Pics/qproc/qtree.png)

## Disk Accesses
Pipelining cannot avoid all disk accesses.

Some operations use **multiple passes** (e.g. merge sort, hash-join).
- Data is written by one pass, read by subsequent passes.

Thus,
- **Within** an operation, disk reads/writes are possible.
- **Between** operations, no disk reads/writes are needed.

## Example PostgreSQL Execution
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/qry-execution/Pics/qproc/qtree2.png)

Note: both left and right child nodes can **execute concurrently** before the result is combined.