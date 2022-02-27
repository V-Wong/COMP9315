# Page Internals
## Pages
Database applications view data as:
- Collection of records/tuples.
- Records can be accessed via ``TupleId/RecordId/RID``.
- ``TupleId = PageID + TupIndex``.

The disk and buffer manager provide the following view:
- Data is a sequence of **fixed-size pages** (aka blocks).
- Pages can be **random-accessed** via a ``PageID``.
- Each page contains zero or more tuple values.

Page format = how space/tuples are organised within a page.

Data files consist of pages containing tuples:
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pages/Pics/storage/data-files.png)

Each data file (in PostgreSQL) is related to **one table**.

## Page Operations
A ``Page`` is simply an **array of bytes** (``byte[]``). We want to interpret/manipulate it as a collection of ``Records`` (tuples).

Tuples are addressed by a record ID (``rid = (PageId, TupIndex)``).

Typical operations on ``Page``s:
- ``request_page(pid)``: get page via ``PageID``.
- ``get_record(rid)``: get record via its ``TupleId``.
- ``rid = insert_record(pid, rec)``: add new record.
- ``update_record(rid, rec)``: update value of record.
- ``delete_record(rid)``: remove record from page.

## Page Formats
Page format = tuples + data structures allowing tuples to be found.

Characteristics of ``Page`` formats:
- Record size **variability** (fixed, variable).
- How **free space** within ``Page`` is managed.
- Whether some data is stored outside ``Page``/
    - Does ``Page`` have an associated **overflow chain**?
    - Are **large data values** stored elsewhere? (e.g. TOAST).
    - Can one tuple span **multiple ``Page``s**.

### Fixed-Length Records
For fixed-length records, use **record slots**:
- **Insert:** place new record in first available slot.
- **Delete:** two possibilities for handling free record slots:

![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pages/Pics/storage/rec-slots.png)

In the **packed representation**, there are **no empty slots between filled slots**. We simply add the record to the end.
- Makes inserting easy as we simply append to the end.
- Deleting is harder as the data must be **compacted**.

In the **unpacked representation**, there may be **empty slots between filled slots**. A bitstring must hence be stored to determine what slots are free.
- Makes insert harder as we have to find a free slot.
- Deleting is easier, as we simply clear out that slot.

### Variable-Length Records
For variable-length records, must use **slot directory**.

Possibilities for handling free-space within block:
- Compacted (one region of free space).
- Fragmented (distributed free space).

In practice, combination is useful:
- Normally fragmented (cheap to maintain).
- Compacted when needed (e.g. record won't fit).

Important aspect of using slot directory:
- Location of tuple within page can change, tuple index does not change.

Compacted free space:
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pages/Pics/storage/free-list.png)

Fragmented free space:
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pages/Pics/storage/free-list1.png)

## Storage Utilisation
The number of records that can fit on a page (with ``C`` denoting capacity) depends on:
- Page size.
- Record size.
- Page header data.
- Slot directory.

## Overflows
Sometimes it may not be possible to insert a record into a page:
- No free-space fragment large enough.
    - Can first try to **compact free-space** within page.
    - If still insufficient space, need alternative solution.
- Overall free-space is not large enough.
    - Can be handled by making **new page**.
- Record is larger than page.
    - Requires **overflow file**.
- No more free directory slots in page.
    - Can be handled by making **new page**.

### Overflow Files for Large Records and BLOBs
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pages/Pics/storage/ovflow-file.png)

### Record-based Handling of Overflows
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pages/Pics/storage/ovflow-record.png)