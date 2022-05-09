# Query Cost Estimation
## Overview
Query optimisers **estimate** costs via:
- Cost of performing operation.
- Size of result (which affects cost of performing next operation).

Result size estimated by **statistical measures on relations**. For example:
- ``r_S``: cardinality of relation ``S``.
- ``R_S``: average size of tuple in relation ``S``.
- ``V(A, S)``: number of distinct values of attribute ``A`` in ``S``.
- ``min(A, S)``: min value of attribute ``A`` in ``S``.
- ``max(A, S)``: max value of attribute ``A`` in ``S``.

## Estimating Projection Result Size
Easy, since we know:
- Number of tuples in output:
    - ``r_out = |π_{a,b,..}(T)| = |T| = r_T`` (in SQL, because of bag semantics).
- Size of tuples in output:
    - ``R_out = sizeof(a) + sizeof(b) + ... + (tuple overhead)``.

Assume page size ``B``:
- ``b_out = ceil(r_T / c_out)`` where ``c_out = floor(B / R_out)``.

If using ``select distinct``:
- ``|π_{a,b,..}(T)|`` depends on **proportion of duplicates** produced.

## Estimating Selection Result Size
**Selectivity:** fraction of tuples expected to **satisfy a condition**.

Common assumption: attribute values **uniformly distributed**. Using this, can incorporate:
- Total number of tuples.
- Total number of distinct values.
- Minimum, maximum values.

### Non-Uniform Attribute Value Distributions
Effective ways to handle non-uniform attribute value distributions:
- Collect **statistics** about the values stored in the attribute/relation.
- Store these as **meta-data** for the relation.

Disadvantage: cost of storing/maintaining statistics.

## Estimating Join Result Size
Analysis relies on **semantic knowledge** about data/relations.

Consider equijoin on common attribute: ``R ⨝_a S``:
- Case 1: ``values(R.a) ∩ values(S.a) = {} ==> size(R ⨝_a S) = 0``.
- Case 2: ``uniq(R.a) and uniq(S.a) ==> size(R ⨝_a S) ≤ min(|R|, |S|)`.
- Case 3: ``pkey(R.a) and fkey(S.a) ==> size(R ⨝_a S) ≤ |S|``.

## Postscript
Above methods can (sometimes) give **inaccurate estimates** that lead to **poor evaluation plans**. To get more accurate cost estimates:
- More time for complex computation of selectivity.
- More space for storage of statistics for data values.

EIther way, optimisation process costs more.

Tradeoff between optimiser performance and query performance.