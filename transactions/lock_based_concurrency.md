# Lock-based Concurrency Control
## Overview
Requires read/write **lock operations** which act on database objects. **Synchronise access** to **shared DB objects** via these rules:
- Before reading ``X``, get read (shared) lock on ``X``.
- Before writing ``X``, get write (exclusive) lock on ``X``.
- A tx attempting to get a read lock on ``X`` is blocked if another tx already has write lock on ``X``.
- A tx attempting to get a write lock on ``X`` is blocked in another tx has any kind of lock on ``X``.

These rules along **do not guarantee serialisability**.

## Lock Mechanisms
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/tx-locking/Pics/txproc/txproc2.png)

**Lock table** entires contain:
- **Object** being locked (Db, table, tuple, field).
- **Type** of lock: read/write, write/exclusive.
- **FIFO queue** of tx's requesting this lock.
- **Count** of tx's currently holding lock (max 1 for write locks).

Lock and unlock operations must be **atomic**.

**Lock upgrade:**
- If a tx holds a read lock, and is is the only tx holding that lock.
- Then the lock can be **converted into a write lock**.

## Two-Phase Locking
To guarantee **serialisability**, we require an additional constraint:
- In every tx, all lock requests precede all unlock requests.

Each transaction is then structured as:
- **Growing phase:** where locks are acquired.
- **Action phase:** where "real work" is done.
- **Shrinking phase:** where locks are released.

Clearly, this **reduces potential concurrency**.

## Problems with Locking
### Deadlock
No transactions can proceed; each **waiting on lock held by another**. 

```
T1: Lw(A) R(A)            Lw(B) .............
T2:            Lw(B) R(B)       Lw(A) .......
```

Handling deadlock involves forcing a transaction to "back off":
- **Select process** to roll back.
    - Choose on basis of how far tx has progressed, # locks, etc.
- **Roll back** the selected process.
    - Worst-case scenario: abort one transaction, then retry.
- Prevent **starvation**.
    - Needs to ensure that same tx isn't always chosen.

#### Deadlock Management Methods
- **Timeout:** set max time limit for each tx.
- **Waits-for graph:** records ``T_j`` waiting on lock held by ``T_k``.
    - **Prevent** deadlock by checking for **new cycle** ==> abort ``T_i``.
    - **Detect** deadlock by **periodic check** for cycles ==> abort ``T_i``.
- **Timestamps:** use tx start times as basis for priority.
    - Scenario: ``T_j`` tries to get lock held by ``T_k``.
    - **Wait-die:** if ``T_j < T_k``, then ``T_j`` waits, else ``T_j`` rolls back.
    - **Wound-wait:** if ``T_j < T_k``, then ``T_k`` rolls back, else ``T_j`` waits.

#### Property of Deadlock Management Methodss
- Both wait-die and wound-wait are **fair**.
- Wait-die tends to:
    - Roll back tx's that have done little work.
    - But rolls back tx's more often.
- Wound-wait tends to:
    - Roll back tx's that may have done significant work.
    - But rolls back tx's less often.
- Timestamps easier to implement than waits-for grpah.
- Waits-for minimises roll backs because of deadlock.