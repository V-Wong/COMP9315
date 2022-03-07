# Cost Model
## DBMS Architecture 
![](https://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/relops/Pics/scansortproj/dbmsarch-relop.png)

## Relational Operations
DBMS core = **relational engine**, with implementations of:
- Selection, projection, join, set operations.
- Scanning, sorting, grouping, aggregation.

## Low Level Functions
Relational operations are supported by low level functions:
    - ``Relation openRel(db, name)``:
        - Gets handle on relation ``name`` in database ``db``.

    - ``Page request_page(rel, pid)``:
        - Get page ``pid`` from relation ``rel``, return buffer containing page.

    - ``Record get_record(buf, tid)``:
        - Return record ``tid`` from page ``buf``.

    - ``Tuple mkTuple(rel, rec)``:
        - Convert record rec to a tuple, based on ``rel`` schema.

Example of using low level functions:

```c
// scan a relation Employees
Page p;  // current page
Tuple t; // current tuple
Relation r = relOpen(db, "Employees");
for (int i = 0; i < nPages(r); i++) {
   p = request_page(rel,i);
   for (int j = 0; j < nRecs(p); j++)
      t = mkTuple(r, get_record(p, j));
      ... process tuple t ...
   } 
}
```

## Dimensions of Variations
There are two dimensions of variations to relational operations:
- Which **relation operation** (e.g. Sel, Proj, Join, Sort, ...).
- Which **access-method** (e.g. file structure: heap, indexed, hashed).

Each **query method** involves an operator and a file structure. Examples:
- Primary-key selection on a hashed file.
- Primary-key selection on indexed file.
- Join on ordered heap file.
- Join on hashed file.
- Two-dimensional range query on R-tree indexed file.

## Analysis of Cost
Two main measures of relational operation **cost**:
- **Time Cost**: total time taken to execute method.
    - Affected by many factors such as:
        - Speed of IO devices.
        - Load on machine.
    - We do not consider time cost in our analyses.
- **Page Cost**: number of pages read and/or written.
    - Better for comparing methods:
        - Identifies workload imposed by method.
    - However is clearly **affected by buffering**.

Quantities in analysis:
- A relation is a set of ``r`` tuples with average tuple size ``R`` bytes.
- Tuples are stored in ``b`` data pages on disk.
- Each page has size ``B`` bytes and contains up to ``c`` tuples.
- Tuples which answer query ``q`` are contained in ``b_q`` pages.
- Data is transferred between disk and memory in whole pages.
- Cost of disk and memory transfer ``T_r/w`` is very high.