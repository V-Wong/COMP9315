# Query Performance Tuning
## Overview
Tuning requires us to consider:
- **Which** queries and transactions will be used?
- **How frequently** does each **query/transaction** occur?
- Are there **time constraints** on queries/transactions?
- Are there **uniqueness constraints** on any attributes?
    - Define indexes on attributes to speed up insertion uniqueness check.
- **How frequently** do **updates** occur?
    - Indexes slow down updates.

Performance can be considered at two times:
- **During** schema design:
    - Typically towards the end of design process.
    - Requires schema transformations such as **denormalisation**.
- **Outside** schema design:
    - Typically after application has been deployed/used.
    - Requires adding/modifying data structures such as **indexes**.

Difficult to predict what query optimiser will do, so:
- Implement queries using methods which "should" be efficient.
- Observe execution behaviour and modify query accordingly.

## PostgreSQL Query Tuning
PostgreSQL provides the **explain* statement to:
- Give a representation of the **query execution plan**.
- With information that may **help to tune query performance**.

