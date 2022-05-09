# Transaction Processing
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/tx-intro/Pics/txproc/dbmsarch.png)

## Overview
A **transaction** (tx) is:
- A **single application-level operation**.
- Performed by a **sequence of database operations**.

A transaction affects a **state change** on the DB.
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/tx-intro/Pics/txproc/tx-exec1.png)

## Transaction States
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/tx-intro/Pics/txproc/tx-states1.png)

``COMMIT`` ==> all changes preserved. ``ABORT`` ==> database unchanged.

## Concurrency
**Concurrent transactions** are:
- Desirable for improved performance (**throughput**).
- Problematic, because of potential **unwanted interactions**.

To ensure problem-free concurrent transactions:
- **Atomic:** whole effect of tx, or nothing.
- **Consistent:** individual tx's are "correct" (wrt. application).
- **Isolated:** each tx behaves as if no concurrency.
- **Durable:** effects of committed tx's persist.

Transaction processing is the study of techniques for **realising ACID properties**.

### Consistency
**Consistency** is the property:
- A tx is **correct** with respect to **its own specification**.
- A tx performs a mapping that **maintains all DB constraints**.

Ensuring this must be left to application programmers.

### Atomicity
**Atomicity** is handled by the **commit** and **abort** mechanisms:
- **Commit** ends tx and ensures all changes are **saved**.
- **Abort** ends tx and **undoes changes** "already made".

### Durability
**Durability** is handled by implementing **stable storage**, via
- **Redundancy:** to deal with **hardware failures**.
- **Logging/checkpoint** mechanisms to **recover state**.

### Isolation
**Isolation** is handled by **concurrency control** mechanisms:
- Possibilities: lock-based, timestamp-based, check-based.
- Various levels of isolation are possible (e.g. serialisation).

## Transaction Terminology
To describe **transaction effects**:
- **READ**: transfer data from disk to memory.
- **WRITE**: transfer data from memory to disk.
- **ABORT**: terminate transaction, unsuccessfully.
- **COMMIT**: terminate transaction, successfully.
- **BEGIN**: starts a transaction.
- **ROLLBACK**: aborts the current transaction, undoing any changes.

Relationship between above operations and SQL:
- ``SELECT` produces READ operations on the database.
- ``UPDATE`` and ``DELETE`` produce READ then WRITE operations.
- ``INSERT`` produces WRITE operations.

### Formalising Transaction Operations
The READ, WRITE, ABORT, COMMIT operations:
- Occur in the context of some transaction ``T``.
- Involve manipulation of data items, ``X, Y``.

The operations are typically denoted as:
- ``R_T(X)``: read item ``X`` in transaction ``T``.
- ``W_T(X)``: write item ``X`` in transaction ``T``.
- ``A_T``: abort transaction ``T``.
- ``C_T``: commit transaction ``T``.

## Schedules
A **schedule** gives the **sequence of operations** for more than 1 tx.

**Serial schedule** for a set of tx's ``T_1, ... , T_n``:
- All operations of ``T_i`` complete before ``T_{i + 1}``.
- Example: ``R_{T_1}(A) W_{T_1}(A) R_{T_2}(B) R_{T_2}(A) W_{T_3}(C) W_{T_3}(B)``.
- Guarantees **DB consistency**.

**Concurrent schedule** for a set of tx's ``T_1, ... , T_n``:
- Operations from individual ``T_i``'s are **interleaved**.
- Example: ``R_{T_1}(A) R_{T_2}(B) W_{T_1}(A) W_{T_3}(C) W_{T_3}(B) R_{T_2}(A)``.
- **Arbitrary interleaving** may produce DB that is **not consistent** after all tx's have committed successfully.

## Transaction Anomalies
The set of problems with **uncontrolled concurrent transactions** can be characterised broadly under:
- **Dirty read**: reading data item written by concurrent **uncommitted** tx.
- **Non-repeatable read:** re-reading **data item (row)**, since **changed** by another concurrent tx.
    - Always the result of an ``UPDATE`` operation.
    - Can be prevented by **locking rows**.
- **Phantom read:** re-scanning **result set (rows plural)**, finding it **changed** by another concurrent tx. 
    - Can be result of ``UPDATE``, ``INSERT`` or ``DELETE`` operation.
    - Can be prevented by **locking table**.