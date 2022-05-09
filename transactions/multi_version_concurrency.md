# Multi-version Concurrency Control
## Overview
MVCC aims to:
- Retain **benefits of locking**, while getting **more concurrency**.
- By providing multiple (consistent) versions of data items.
- Each transaction sees **consistent** but **not necessarily current** version of database.

Achieves this by:
- Readers access an **appropriate version** of each data item.
- Writers make **new versions** of the data items they specify.

Main difference between MVCC and standard locking:
- Read locks **do not conflict** with write locks
- ==> Reading never blocks writing, writing never blocks reading.

## Timestamps
**WTS** = timestamp of tx that wrote this data item.

Chained tuple versions: ``tup_oldest -> tup_older -> tup_newest``.

When a **reader** ``T_i`` is accessing the database:
- Ignore any data item ``D`` created after ``T_i`` started.
    - Checked by: ``WTS(D) > TS(T_i)``.
- Use only newest version ``V`` accessible to ``T_i``.
    - Determined by: ``max(WTS(V)) < TS(T_i)``.

When a **writer** ``T_i`` attempts to change a data item.
- Find newest version ``V`` satisfying ``WTS(V) < TS(T_i)``.
- If no later versions exist, create new version of data item.
    - No changes made since this transaction started, can safely update.
- If there are later versions, then abort ``T_i``.
    - Change made since this transaction started, can't safely update.

Some MVCC versions also maintain RTS (TS of last reader):
- Don't allow ``T_i`` to write ``D`` if ``RTS(D) > TS(T_i)``.

## Advantages and Disadvantages
**Advantages:**
- Locked needed for serialisability considerably reduced.

**Disadvantages:**
- **Visibility-check overhead** (on every tuple read/write).
- Reading an item ``V`` causes an update of ``RTS(V)``.
- **Storage overhead** for extra versions of data items.
- Overhead in **removing out-of-date versions** of data items.

Despite apparent disadvantages, MVCC is **very effective**.

## Removing Old Versions
Removing old versions:
- ``V_j`` and ``V_k`` are versions of same item.
- ``WTS(V_j)`` and ``WTS(V_k)`` precede ``TS(T_i)`` for all ``T_i``.
- Remove version with smaller ``WTS(V_x)`` value.

Possible times to make this check:
- Every time a new version of data item is added.
- Periodically, with fast access to blocks of data.

