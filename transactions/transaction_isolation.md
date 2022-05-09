# Transaction Isolation
## Overview
**Serial execution** (``T1 ; T2; T3 ;...``) is the simplest form of **isolation**.

Problem: serial execution yields **poor throughput**.

**Concurrency control schemes** (CCSs) aim for "safe" concurrency.

Abstract view of DBMS concurrency mechanisms:
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/tx-isolation/Pics/txproc/txproc1.png)

## Serialisability
Consider two schedules ``S1`` and ``S2`` produced by:
- Executing the **same set of transactions** ``T1 .. Tn`` concurrently.
- But with a **non-serial interleaving** of read/write operations.

``S1`` and ``S2`` are **equivalent** if ``StateAfter(S1) == StateAfter(S2)``.
- This is a very restrictive requirement.

``S`` is a **serializable schedule** if ``S`` is equivalent to some serial schedule ``S'`` of ``T1 .. Tn``.
- This is a less restrictive requirement.
- Enough to **guarantee consistency**.

### Classes of Serialisability
**Conflict serialisability:**:
- Conflicting read/write operations occur in the "right order".
- Check via **precdence graph**; look for **absence of cycles**.

**View serialisability:**
- Read operations see the correct version of data.
- Check via VS conditions on likely equivalent schedules.

View serialisability is **strictly weaker** than conflict serialisability.

### Checking Conflict Serialisability
```
construct graph with just nodes, one for each T_i.
for each pair of operations across transactions:
    if T_i and T_j have conflicting ops on variable X:
        put directed edge between T_i and T_j 
        where direction goes from  first tx to access X
        to second tx to access X

    if this new edge forms a cycle:
        return NotConflictSerialisable

return ConflictSerialisable
```

### Checking View Serializability
```
// T_{C,i} denotes transaction i in concurrent schedule
for each serial schedule S:
    for each shared variable X:
        if T_{C, i} reads same version of X as T_{S, i}
            (either initial value or value written by T_j)
            continue
        else
            give up on this serial schedule
        if T_{C, i} and T_{S, i} write the final version of X:
            continue
        else:
            give up on this serial schedule

    return ViewSerialisable

return NotViewSerialisable
```

## Transaction Isolation Levels
SQl programmers' concurrency control mechanism:

```sql
set transaction
    read only  -- so weaker isolation may be ok
    read write -- suggests stronger isolation needed
isolation level
    -- weakest isolation, maximum concurrency
    read uncommitted
    read committed
    repeatable read
    serializable
    -- strongest isolation, minimum concurrency
```

### Implication of Isolation Levels

|Isolation Level|Dirty Read|Non-repeatable Read|Phantom Read|
|----|----|----|----|
|Read Uncommitted|Possible|Possible|Possible|
|Read Committed|Not Possible|Possible|Possible|
|Repeatable Read|Not Possible|Not Possible|Possible|
|Serialisable|Not Possible|Not Possible|Not Possible|

### View of Database
A PostgreSQL tx consists of a sequence of SQL statements:

```sql
BEGIN S_1; S_2; ... S_n; COMMIT;
```

Isolation levels affect view of DB provided to each ``S_i``.
- **Read Committed:**
    - Each ``S_i`` sees snapshot of DB at start of ``S_i``.
        - This snapshot **does NOT include any uncommitted changes** from other concurrent tx's.
        - This snapshot **may however include committed changes** from other concurrent tx's.
- **Repeatable Read** and **Serialisable:**
    - Each ``S_i`` sees snapshot of DB at start of tx.
        - This snapshot **does NOT include even committed changes** from other concurrent tx's.
    - Serialisable checks for extra conditions.

Transactions fail if the system detects violation of isolation level.

### Repeatable Read vs Serialisable
Table ``R(class, value)`` containing ``(1,10) (1,20) (2,100) (2,200)``.
- ``T1: X = sum(value) where class=1; insert R(2,X); commit``.
- ``T2: X = sum(value) where class=2; insert R(1,X); commit``.
- With repeatable read, **both transactions commit**, giving:
    - Updated table: ``(1,10) (1,20) (2,100) (2,200) (1,300) (2,30)``.
- With serial transactions, only **one transaction commits**:
    - ``T1;T2`` gives ``(1,10) (1,20) (2,100) (2,200) (2,30) (1,330)``.
    - ``T2;T1`` gives ``(1,10) (1,20) (2,100) (2,200) (1,300) (2,330)``.
- PG recognises that committing both gives **serialisation violations**.

## Concurrency Control
Isolation requires some method to **control concurrency**.

Possible approaches to implementing concurrency control:
- **Lock-based:**
    - Synchronise tx execution via locks on relevant part of DB.
- **Version-based (multi-version concurrency control):**
    - Allow **multiple consistent versions** of the data to exist.
    - Each tx has access only to version existing at start of tx.
- **Validation-based (optimistic concurrency control):**
    - Execute all tx's; check for validity problems **on commit**.
- **Timestamp-based:**
    - Organise tx execution via timestamps assigned to actions.

    