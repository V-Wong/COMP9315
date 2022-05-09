# Implementing Recovery
## Overview
For a DBMS to recover from a system failure, it needs:
- Mechanism to **record what updates were in progress** at failure time.
- Methods for **restoring the database** to valid state afterwards.

Assume **multiple transactions** are running when failure occurs:
- Uncommitted transactions need to be **rolled back** (``ABORT``).
- Committed, but not yet finalised tx's need to be **completed**.

A critical mechanism in achieving this is

## Logging
All logging approaches require:
- A **sequential file** of log records.
- Each log record describes a **change** to a data item.
- **Log records** are written **before changes to data**.
- **Actual changes** to data are **written later**.

### Undo Logging
**Undo logging** removes changes by any uncommitted tx's.

Log file consists of a sequence of small records:
- ``<START T>``: transaction ``T`` begins.
- ``<COMMIT T>``: transaction ``T`` completes successfully.
- ``<ABORT T>``: transaction ``T`` fails (no changes).
- ``<T, X, v>``: transaction ``T`` changed value of ``X`` from ``v``.
    - Note: generically referred to as ``<UPDATE>``.
    - Note: new value not recorded.

Notes:
- Update log entry created for each ``WRITE`` (not ``OUTPUT``).

#### Steps in Undo Logging
Data must be written to disk in the following order:
1. ``<START>`` transaction log record.
2. ``<UPDATE>`` log records indicate changes.
3. Changed data elements themselves.
4. ``<COMMIT>`` log record.

#### Recovery in Undo Logging
Scan **backwards** through log:
- If ``<COMMIT T>``, mark ``T`` as committed.
    - ``T`` completed successfully, no problem here.
- If ``<T, X, V>`` and ``T`` not committed, set ``X`` to ``v`` on disk.
    - Reversing any updates made.
- If ``<START T>`` and ``T`` not committed, put ``<ABORT T>``.
    - Successfully rolled back the entirety of ``T``.

Assumes we scan entire log; use checkpoints to limit scan.

Algorithm:
```
committedTrans = abortedTrans = startedTrans = {}
for each log record from most recent to oldest {
    switch (log record) {
    <COMMIT T> : add T to committedTrans
    <ABORT T>  : add T to abortedTrans
    <START T>  : add T to startedTrans
    <T,X,v>    : if (T in committedTrans)
                     // don't undo committed changes
                 else  // roll-back changes
                     { WRITE(X,v); OUTPUT(X) }
}   }
for each T in startedTrans {
    if (T in committedTrans) ignore
    else if (T in abortedTrans) ignore
    else write <ABORT T> to log
}
flush log
```

### Checkpointing
Log file grows without bound. Eventually we can **delete old section** of log:
- Where **all** prior transactions have committed.

This point is called a **checkpoint**.
- All of log prior to checkpoint can be ignored for recovery.

#### Challenges in Checkpointing
Problem: many **concurrent/overlapping transactions**. How to determine that **all have finishe**d:
1. Periodically, write log record ``<CHKPT(T1, .. , Tk)>``
    - Contains reference to all active tx's ==> active tx table.
2. Continue normal processing (e.g. new tx's can start)
3. When all of ``T1, .., T_k`` have completed, write log record ``<ENDCHKPT>`` and flush log.

Note: tx manager maintains chkpt and active tx information.

#### Recovery with Checkpointing
Recovery: scan backwards through log file processing as before.

Determining where to stop depends on:
- If we meet ``<ENDCHKPT>`` first or ``<CHKPT...>`` first.

If we encounter ``<ENDCHKPT>`` first:
- We know that all incomplete tx's come after previous ``<CHKPT...>``.
- Thus, can stop backward scan when we reach ``<CHKPT...>``.

If we encounter ``<CHKPT(T1, ... , Tk)>`` first:
- Crash occurred during the checkpoint period.
- Any of ``T1, ... , Tk`` that committed before crash are ok.
- For uncommitted tx's, need to continue backward scan.

### Redo Logging
Problem with undo logging:
- All changed data must be **output to disk** before committing.
- Conflicts with optimal use of the buffer pool.

Alternative approach is **redo logging**:
- Allow changes to remain only in buffers after commit.
- Write records to indicate what changes are "pending".
- After a crash, can apply changes during recovery.

#### Steps in Redo Logging
Requirement for redo logging: **write-ahead rule**.

Data must be written to disk as follows:
1. Start transaction log record.
2. Update log records indicating changes.
    - Update log records now contain ``<T, X, v'>`` where ``v'`` is the **new value** for ``X``.
3. Then commit log record (``OUTPUT``).
4. Then ``OUTPUT`` changed data elements.

Note: actual writing of data items happens AFTER commit.

#### Recovery in Redo Logging
Simplified view of recovery:
- Identify all committed tx's (backwards scan).
- Scan **forwards** through log:
    - If ``<T, X, v>`` and ``T`` is committed, set ``X`` to ``v`` on disk.
    - If ``<START T>`` and ``T`` not committed, put ``<ABORT T>`` ing log.

### Undo/Redo Logging
Undo and redo logging are **incompatible** in:
- Order of outputting ``<COMMIT T>`` and changed data.
- How data in buffers is handled during checkpoints.

Undo/Redo logging **combines aspects of both**:
- Requires new update log record ``<T, X, v, v'>`` that gives both old and new values for ``X``.
- Removes incompatibilities between output orders.

#### Recovery in Undo/Redo Logging
Simplified view of recovery:
- Scan log to determine committed/uncommitted tx's.
- For each uncommitted tx ``T``, add ``<ABORT T>`` to log.
- Scan **backwards** through log:
    - If ``<T, X, v, w>`` and ``T`` is not committed, set ``X`` to ``v`` on disk.
- Scan **forwards** through log:
    - If ``<T, X, v, w>`` and ``T`` is committed, set ``X`` to ``w`` on disk.