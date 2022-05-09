# Durability
## Dealing with Transactions
The remaining failure modes that we consider:
- Failure of DBMS processes or OS.
- Failure of transactions (``ABORT``).

Standard technique for managing these:
- Keep a **log** of changes made to database.
- Use this log to **restore state** in case of failures.

## DBMS Architecture for Atomicity/Durability
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/tx-durability/Pics/txproc/arch.png)

## Execution of Transactions
Transactions deal with 3 **address/memory spaces**:
- Data on disk (persistent DB state).
- Data in memory buffers (held for sharing by tx's).
- Data in own local variables (where manipulated).

Each of these may hold a **different version** of a DB object.

### Transaction Operations
Operations available for data transfer:
- ``INPUT(X)``: read page containing ``X`` into a buffer.
- ``READ(X, v)``: copy value of ``X`` from buffer to local variable ``v``.
    - May cause ``INPUT`` if value not in buffer.
- ``WRITE(X, v)``: copy value of local variable ``v`` to ``X`` in buffer.
    - May cause ``OUTPUT`` depending on implementation details.
- ``OUTPUT(X)``: write buffer containing ``X`` to disk.

``READ``/``WRITE`` are issued by transaction.
``INPUT``/``OUTPUT`` are issued by buffer manager (and log manager).

### Transactions and Buffer Pool
Two issues w.r.t. buffers:
- **Forcing:** ``OUTPUT`` buffer on each ``WRITE``.
    - **Ensures durability:** disk always consistent with buffer pool.
    - **Poor performance:** defeats purpose of having buffer pool.
- **Stealing:** replace buffers of uncommitted tx's:
    - **Poor throughput** if we don't (tx's blocked on buffers).
    - Potential atomicity issues as **uncommitted changes** are **written to disk**.

#### Stealing vs No Forcing
Handling **stealing:**
- Transaction ``T`` loads page ``P`` and makes changes.
- ``T_2`` needs a buffer, and ``P`` is the victim.
- ``P`` is output to disk (it's dirty) and replaced.
- If ``T`` aborts, some of its changed are already "committed".
- Must **log values** changed by ``T`` in ``P`` **at steal time**.
- Use these to **undo changes** in case of failure of ``T``.

Handling **no forcing:**
- Transaction ``T`` makes changes and commits, then system crashes.
- But what if modified page ``P`` not yet output.
- Must **log values** changed by ``T`` in ``P`` as soon as they change.
- Use these to support **redo** to restore changes.

