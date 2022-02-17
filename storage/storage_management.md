# Storage Management
## Low Level View
![](http://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/storage/Pics/storage/dbmsarch.png)

## Storage Technology
**Persistent** storage is:
- Large, cheap, relatively slow, **accessed in blocks**.
- Used for **long-term storage** of data.

**Computational** storage is:
- Small, expensive, fast, **accessed by byte/word**.
- Used for all analysis of data.

### Comparison of Storage Devices

||RAM|HDD|SDD|
|----|----|----|----|
|Read latency|~1 micro|~10 milli|~50 micro|
|Write latency|~1 micro|~10 milli|~900 micro|
|Read unit|byte|block (e.g. 1 KB)|byte|
|Writing|byte|write a block|write on empty block|

## Aim of DBMS
Aims of storage management in DBMS:
- Provide view of data as collection of pages/tuples.
- Map from database objects (e.g. tables) to disk files.
- Manage transfer of data to/from disk storage.
- Use buffers to minimize disk/memory transfers.
- Interpret loaded data as tuples/records.
- Basis for file structures used by access methods.

### Views of Data in Query Evaluation
![](http://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/storage/Pics/storage/query-ops.png)

### Representing Database Objects During Query Execution
- ``DB`` (handle on an authorized/opened database).
- ``Rel`` (handle on an opened relation).
- ``Page`` (memory buffer to hold contents of disk block).
- ``Tuple`` (memory holding data values from one tuple).

Addressing in DBMSs:
- ``PageID = FileID + Offset`` identifies a block of data.
    - Where ``Offset`` gives location of block within file.
- ``TupleId = PageId + Index`` identifies a single tuple.
    - Where ``Index`` gives location of tuple within page.

## Topics In Storage Management
- Disks and files.
    - Performance issues and organization of disk files.
- Buffer management.
    - Using caching to improve DBMS system throughput.
- Tuple/Page management.
    - How tuples are represented within disk pages.
- DB Object Management (Catalog).
    - How tables/views/functions/types, etc are represented.

## Cost Models
Important aspects in determining costs of DB operations:
- Data is always transferred to/from disk as whole blocks (pages).
- Cost of manipulating tuples in memory is negligible.
- Overall cost determined primarily by #data-blocks read/written.

Complicating factors in determining costs:
- Not all page accesses require disk access (buffer pool).
- Tuples typically have variable size (tuples/page?).