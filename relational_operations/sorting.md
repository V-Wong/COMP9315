# Sorting
## Two-way Merge Sort
For large data on disks, **external sorts** are needed.

![](https://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/sorting/Pics/scansortproj/two-way-ex2.png)

Requires **at least 3 buffers**:
![](https://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/sorting/Pics/scansortproj/two-way-buf.png)

### Cost of Two-way Merge Sort
For a file containing ``b`` data pages:
- Require ``ceil(log_2(b))`` passes to sort.
- Each pass requires ``b`` page reads, ``b`` page writes.
- Gives total cost: ``2 * b * ceil(log_2(b))``.

## n-way Merge Sort
**Initial pass** uses ``B`` total buffers. ``B`` pages are read at a time, sorted and then written back to memory. Creates a sorted run of length ``B`` pages.

![](https://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/sorting/Pics/scansortproj/n-way-buf-pass0.png)

**Merge passes** uses ``b = B - 1`` input buffers, 1 output buffer.

![](https://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/sorting/Pics/scansortproj/n-way-buf.png)

Method:
```c
// Produce B-page-long runs
for each group of B pages in Rel {
    read B pages into memory buffers
    sort group in memory
    write B pages out to Temp
}
// Merge runs until everything sorted
numberOfRuns = ceil(b/B)
while (numberOfRuns > 1) {
    // n-way merge, where n=B-1
    for each group of n runs in Temp {
        merge into a single run via input buffers
        write run to newTemp via output buffer
    }
    numberOfRuns = ceil(numberOfRuns/n)
    Temp = newTemp // swap input/output files
}
```

### Cost of n-Way Merge Sort
Consider file where ``b = 4096`` pages and ``B = 16`` total buffers:
- Pass 0:
    - Produces 256 * 16-page sorted runs.
- Pass 1:
    - Performs 15-way merge of groups of 16-page sorted runs.
    - Produces 18 * 240-page sorted runs (17 full runs, 1 short run).
- Pass 2:
    - Performs 15-way merge of groups of 240-page sorted runs.
    - Produces 2 * 3600-page sorted runs (1 full run, 1 short run).
- Pass 3:
    - Performs 15-way merge of groups of 3600-page sorted runs.
    - Products 1 * 4096 page sorted runs.

Generalizing using ``b`` data pages and ``B`` buffers:
- First pass: read/write ``b`` pages, gives ``b_0 = ceil(b / B)`` runs.
- Then need ``ceil(log_n(b_0))`` passes until sorted, where ``n = B - 1``.
- Each pass reads and writes ``b`` pages.
- Total cost: ``2 * b * (1 + ceil(log_n(b_0)))``.

## Sorting in PostgreSQL
PostgreSQL uses a similar merge sort to above.

Tuples are mapped to ``SortTuple`` structs for sorting:
- Containing pointer to tuple and sort key.
- **No need to reference actual Tuples** during sort.
- Unless **multiple attributes** used in sort.

If all data fits in memory, sort using ``qsort()``.

If **memory fills** while reading, form "runs" and do **disk-based sort**.

Disk-based sort has phases:
- Divide input into **sorted runs** using HeapSort.
- **Merge** using ``N`` buffers, one output buffer.
- ``N`` = as many buffers as ``workMem`` allows.

Sorting comparison operators are obtained via catalog:
```
// gets pointer to function via pg_operator
struct Tuplesortstate { ... SortTupleComparator ... };

// returns negative, zero, positive
ApplySortComparator(Datum datum1, bool isnull1,
                    Datum datum2, bool isnull2,
                    SortSupport sort_helper);
```
