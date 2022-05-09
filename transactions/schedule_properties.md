# Properties of Schedules
## Serializable Schedules
A concurrent schedule on a set of tx's ``TT`` is serialisable if:
- It produces the **same effect as a serial schedule** on ``TT``.

A goal of isolation mechanisms is:
- To **arrange execution** of **individual operations** in tx's in ``TT``.
- To ensure that a **serializable schedule is produced**.

Serialisability is a property of a schedule focusing on **isolation**. Other properties focus on **recovering from failures**.

Producing a **serialisable schedule**:
- Eliminates all update anomalies (GOOD).
- May reduce opportunity for concurrency (BAD).
- May reduce overall throughput of system (BAD).

If DB programmers know update anomalies are unlikely/tolerable:
- Serialisable schedules **may not be necessary**.
- Some DBMSs offer **less strict isolation levels** (e.g. repeatable read).
- Allowing opportunity for **more concurrency**.

## Transaction Failure
Problems arise when transactions **abort**. Consider the following schedule where ``T1`` fails:

```
T1: R(X) W(X) A
T2:             R(X) W(X) C
```

There are 3 places where the rollback might occur:
```
T1: R(X) W(X) A [1]     [2]        [3]
T2:                 R(X)    W(X) C
```

Case 1 (GOOD):
- All effects of ``T1`` vanish; final effect is simply from ``T2``.

Case 2 (BAD):
- Some of ``T1``'s effects persist, even though ``T1`` aborted.

Case 3 (BAD):
- ``T2``'s effects are lost, even though ``T2`` committed.

## Recoverability
### Motivating Example
Consider the serialisable schedule:

```
T1:        R(X)  W(Y)  C
T2:  W(X)                 A
```

(where final value of ``Y`` is dependent on ``X`` value)

Notes:
- Final value of ``X`` is valid (change from ``T2`` rolled back).
- ``T1`` reads/uses ``X`` value that is eventually rolled-back.
- Even though ``T2`` is correctly aborted, it has produced an **effect**.

This produces an **invalid database state**, even though serialisable.

### Recoverable Schedules
**Recoverable schedules:**
- Have transactions commit only AFTER all transactions whose changes they read commit.
    - Formally: All tx's ``T_i`` that write values used by ``T_j`` must commit BEFORE ``T_j`` commits.
- Ensures a transaction does not commit a value written/updated by another transaction that is eventually rolled-back.
- Note: does NOT prevent dirty reads.

In order to make schedules recoverable, may need to **abort multiple transactions**.

### Cascading Aborts
Recall the non-recoverable schedule:

```
T1:        R(X)  W(Y)  C
T2:  W(X)                 A
```

To make it recoverable requires:
- Delaying ``T1``'s commit until ``T2`` commits.
- If ``T2 `` aborts, cannot allow ``T1`` to commit.

```
T1:        R(X)  W(Y) ...   C? A!
T2:  W(X)                 A
```

This is known as **cascading aborts**.

Another example:

```
T1:                    R(Y)  W(Z)        A
T2:        R(X)  W(Y)                 A
T3:  W(X)                          A
```

``T3`` aborts, causing ``T2`` to abort, causing ``T1`` to abort even though ``T1`` has no shared data with ``T3``.

This kind of problem:
- Can potentially affect **very many concurrent transactions**.
- Could have significant impact on **system throughput**.

### Alternative to Cascading Aborts
Cascading aborts can be avoided if:
- Tx's can only read values **written by committed transactions**.
    - Alternatively: no tx can read data items written by an uncommitted tx.

Effectively: **eliminate** the possibility of **reading dirty data**.

Downside: **reduces** opportunity for **concurrency**.

These are known as ACR (**avoid cascading rollback**) schedules. All ACR schedules are **also recoverable**.

## Strictness
**Strict** schedules also **eliminate** the chance of **writing dirty data**.

A schedule is **strict** if:
- No tx can read values written by another uncommitted tx (ACR).
- No tx can write a data item written by another uncommitted tx.

Strict schedules **simplify rolling back** after aborts.

### Example of Non-strict Schedule
```
T1:  W(X)        A
T2:        W(X)     A
```

Problems with handling rollback after aborts:
- When ``T1`` aborts, don't rollback (need to retain value written by ``T2``).
- When ``T2`` aborts, need to rollback to pre-``T1`` (not just pre-``T2``, as this would have the effect of ``T1``).

## Classes of Schedules
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/tx-schedules/Pics/txproc/schedules.png)

DBMSs allow users to trade off "safety" (seralisability and strictness) against performance.