# Optimistic Concurrency
## Overview
Locking is a **pessimistic** approach to concurrency control.
- Limit concurrency to ensure that conflicts don't occur.

Costs: lock management, deadlock handling, contention.

In scenarios with far **more reads than writes**:
- Don't lock (allow arbitrary interleaving of operations).
- Check just before commit that no conflicts occurred.
- If problems, roll back conflicting transactions.

**Optimistic concurrency control** (OCC) is a strategy to realise this.

## Stages of OCC
OCC has 3 distinct phases:
1. **Reading:** read from database, **modify local copies** of data.
2. **Validation:** check for conflicts in updates.
3. **Writing:** commit local copies of data to database.

![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/tx-optimistic/Pics/txproc/occ-phases.png)

### Validation
Data structures needed for validation:
- S: set of txs that are reading data and computing results.
- V: set of txs that have reached validation (not yet committed).
- F: set of txs that have finished (committed data to storage)/
- For each ``T_i``, timestamps for when it reached S, V, F.
- ``RS(T_i)``: set of all data items read by ``T_i``.
- ``WS(T_i)``: set of all data items to be written by ``T_i``.

Use the V timestamps as ordering for transactions.
- Assume serial tx order based on ordering of ``V(T_i)``'s.

#### Two-transaction Example
Overview:
- Allow transactions ``T_1`` and ``T_2`` to run without any locking.
- Check that objects used by ``T_2`` are not being changed by ``T_1``.
- If they are, need to roll back ``T_2`` and retry.

Case 0: serial execution, no problem.

![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/tx-optimistic/Pics/txproc/occ0.png)

Case 1: reading overlaps validation/writing.
- ``T_2`` starts while ``T_1`` is validating/writing.
- If some ``X`` being read by ``T_2`` is in ``WS(T_1)``.
- Then ``T_2`` may not have read the updated version of ``X``.
- So, ``T_2`` must start again.

![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/tx-optimistic/Pics/txproc/occ1.png)

Case 2: reading/validation overlaps validation/writing.
- ``T_2`` starts validating while ``T_1`` is validating/writing.
- If some ``X`` being written by ``T_2`` is in ``WS(T_1)``.
- Then ``T_2`` may end up overwriting ``T_1``'s update.
- So, ``T_2`` must start again.

#### Summary of Validation Checks
For all transactions ``T_i =/= T``:
- If ``T ∈ S and T_i ∈ F``, then ok.
- If ``T ∉ V and V(T_i) < S(T) < F(T_i)``, then check ``WS(T_i) ∩ RS(T)`` is empty.
    - ``T`` may be reading an old value that ``T_i`` has changed and not yet committed.
- If ``T ∈ V and V(T_i) < V(T) < F(T_i)``, then check ``WS(T_i) ∩ WS(T)`` is empty.
    - ``T`` may end up overwriting a value that ``T_i`` has written.

If this check fails for any ``T_i``, then ``T`` is rolled back.

## Summary
OCC prevents: ``T`` reading dirty data, ``T`` overwriting ``T_i``'s changes.

Problems with OCC:
- Increased roll backs.
- Tendency to roll back "complete" tx's.
- Cost to maintain S, V, F sets.

Roll back is relatively cheap:
- Changes to data are purely local before writing phase.
- No requirement for logging info or undo/redo.