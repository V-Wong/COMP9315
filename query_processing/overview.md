# Query Processing Overview
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/qry-processing/Pics/qproc/dbmsarch.png)

## What is Query Processing
A **query evaluator/processor**:
- Takes **declarative description** of query (in SQL).
- **Parses query** to internal representation (relation algebra).
- **Determines plan** for answering query (expressed as DBMS ops).
- **Executes method** via DBMS engine (to produce result tuples).

## Internals of Query Evaluator
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/qry-processing/Pics/qproc/qproc0.png)

## Relational Algebra Operations
DBMSs provide **several variants** of each RA operation. These **specialised versions** of RA operations are called **RelOps**.

Major task of query processor:
- Given a RA expression to be evaluated.
- **Find combination of RelOps** to do this **efficiently**.

Requires the query translator/optimiser to consider:
- Information about relations (sizes, primary keys, ...).
- Information about operations (e.g. selection reduces size).

RelOps are realised at **execution time:**
- As a collection of **inter-communicating nodes**.
- Communicating either via **pipelines** or **temporary relations**.

## Terminology Variations
RA expression of SQL query:
- Intermediate query representation.
- Logical query plan.

Execution plan as collection of RelOps:
- Query evaluation plan.
- Query execution plan.
- Physical query plan.

Representations of RA operators and expressions:
- ``σ = Select = Sel``.
- ``π = Project = Proj``.
- ``R ⨝ S = R Join S = Join(R,S)``.
- ``∧ = &, ∨ = |``.