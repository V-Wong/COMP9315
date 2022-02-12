# Relational Algebra
## Overview of Relational Algebra
Relational algebra (RA) can be viewed as:
- **Mathematical system** for **manipulating relations**, or
- **Data manipulation language** (DML) for the relational model.

Relational algebra consists of:
- **Operands**: relations, or variables representating relations.
- **Operators** that map relations to relations.
- Rules for **combining operands/operators** into expression.
- Rules for **evaluating such expressions**.

RA can be viewed as the **machine language** for RDBMS.

## Common Relational Algebra Operations
### Selection
Returns a subset of the tuples in a relation ``r`` that **satisfy a specified condition** ``C``.

```
σC(r) = Sel[C](r) = { t ∈ r | C(t) }, where r(R)
```

### Projection
Returns a set of tuples containing a **subset of attributes** ``X`` in the original relation.

```
πX(r) = Proj[X](r) = { t[X] | t ∈ r }, where r(R)
```

### Union
```
r1 ∪ r2 = { t | t ∈ r1 ∨ t ∈ r2 }, where r1(R), r2(R)
```

Requires both relations to have the same schema.

### Intersection
```
r1 ∩ r2 = { t | t ∈ r1 ∧ t ∈ r2 }, where r1(R), r2(R)
```

Requires both relations to have the same schema.

### Difference
```
r1 - r2 = { t | t ∈ r1 ∧ ¬ t ∈ r2 }, where r1(R), r2(R)
```

Requires both relations to have the same schema.

### Cartesian Product
```
r × s = { (t1 : t2) : t1 ∈ r ∧ t2 ∈ s }, where r(R), s(S) 
```

### Natural Join
A specialised product:
- Containing only pairs that **match on their common attributes**.
- With **one of each pair** of common attributes **eliminated** (so we don't duplicate that column).

Consider relation schemas ``R(ABC...JKLM), S(KLMN...XYZ)``. The natural join of ``r(R)`` and ``s(S)`` is defined as:

```
r ⋈ s = r Join s =  
{ (t1[ABC..J] : t2[K..XYZ])  |  t1 ∈ r ∧ t2 ∈ s ∧ match }
where 
    match = (t1[K] = t2[K] ∧ t1[L] = t2[L] ∧ t1[M] = t2[M])
```

Can also be defined in terms of other relational algebra operations:
```
r Join s = Proj[R ∪ S] (Sel[match] (r × s))
```

### Theta Join
A specialised product containing only pairs that **match on a supplied condition** ``C``.

```
r ⋈C s = { (t1 : t2)  |  t1 ∈ r ∧ t2 ∈ s ∧ C(t1 : t2) },
where r(R), s(S)
```

Can be defined in terms of other RA operations:

```
r ⋈C s = rJoin[C]s = Sel[C](r x s)
```

### Outer join
``r Join s`` eliminates all ``s`` tuples that do not match some ``r`` tuple.

Sometimes, we wish to keep this information, so outer join
- Includes all tuples from each relation in the result.
- For pairs of matching tuples, concatenate attributes as for standard join.
- For tuples that have no match, assign ``null`` to unmatched attributes.

### Aggregation
Two types of aggregation are common in database queries:
- Accumulating summary values for data in tables:
    - Typical operations: ``sum``, ``average``, ``count``.
    - Many operations work on a single column.
- Grouping sets of tuples with common values
    - ``GroupBy[A_1...A_n](R)``.
    - Typically we group using only a single attribute.

### Generalised Projection
In standard projection, we select values of specified attributes. In generalised projection, we perform some computation on the attribute value before placing it in the result tuple. Examples:
- Display branch assets in AUD intead of AUD.
- Display employee records using age rather than birthday.