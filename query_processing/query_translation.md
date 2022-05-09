# Query Translation
## Overview
**Converts** SQL statement text to RA expression.

**Processes:**
- Lexer/parser.
- Mapping rules.
- Rewriting rules.

Mapping from SQL to RA may include some **optimisations**.

## Parsing SQL
Parsing task is similar to that for programming languages.

## Expression Rewriting Rules
Since RA is a **well-defined formal system**:
- There exist many **algebraic laws** on RA expressions.
- Which can be used as a basis for expression rewriting.
- In order to produce **equivalent** (potentially more efficient) expressions.

**Expression transformation** based on such rules can be used:
- To simplify/improve SQL to RA mapping results.
- To generate new **plan variations** to check in query optimisation.

## Relational Algebra Laws
**Commutative and Associative Laws:**
- ``R ⨝ S = S ⨝ R, (R ⨝ S) ⨝ T = R ⨝ (S ⨝ T)`` (natural join).
- ``R ∪ S = S ∪ R, (R ∪ S) ∪ T = R ∪ (S ∪ T)`` (normal set algebra rules).
- ``R ⨝_Cond S = S ⨝_Cond R `` (theta join).
- ``σ_c(σ_d(R)) = σ_d(σ_c(R))``.

**Selection splitting:**
- ``σ_c∧d(R) = σ_c(σ_d(R))``.
- ``σ_c∨d(R) = σ_c(R) ∪ σ_d(R)``.

**Selection pushing:**
- ``σ_c(R ∪ S) = σ_c(R) ∪ σ_c(S)``.
- ``σ_c(R ∩ S) = σ_c(R) ∩ σ_c(S)``.

**Selection pushing with join:**
- ``σ_c(R ⨝ S) = σ_c(R) ⨝ S`` (if ``c`` refers only to attributes from ``R``).
- ``σ_c(R ⨝ S) = R ⨝ σ_c(S) `` (if ``c`` refers only to attributes from ``S``).
- If condition contains attributes from both ``R`` and ``S``:
    - ``σ_c′∧c″ (R ⨝ S) = σ_c′(R) ⨝ σ_c″(S)``.
    - Where ``c'`` contains only ``R`` attributes and ``c''`` contains only ``S`` attributes.

**Projection:**
- All but last project can be ignored:
    - ``π_L1(π_L2(...π_Ln (R))) ==> π_L1(R)``.
- Projections can be pushed into joins:
    - ``π_L(R ⨝c S) = π_L(π_M(R) ⨝c π_N(S))``
    - Where ``M`` and ``N`` must contain all attributes needed for ``c`` and ``M`` and ``N`` must contain all attributes used in ``L`` (``L ⊆ M ∪ N``).

## Query Rewriting
Subqueries are converted to joins when possible.

### PostgreSQL Views
In PostgreSQL, views are implemented via rewrite rules.
- A reference to view in SQL expands its definition in RA.

For example:
```sql
create view COMP9315studes as
select stu,mark from Enrolments where course='COMP9315';
-- students who passed
select stu from COMP9315studes where mark >= 50;
```

is represented as:
```
COMP9315studes
  = Proj[stu,mark](Sel[course=COMP9315](Enrolments))
-- with query ...
Proj[stu](Sel[mark>=50](COMP9315studes))
-- becomes ...
Proj[stu](Sel[mark>=50](
  Proj[stu,mark](Sel[course=COMP9315](Enrolments)))
)
-- which could be rewritten as ...
Proj[stu](Sel[mark>=50 & course=COMP9315]Enrolments)
```