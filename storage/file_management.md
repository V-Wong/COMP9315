# File Management
## Aims of File Management Subsystem
- Organize **layout of data** within FS.
- Handle **mapping** from database ID to file address.
- **Transfer** blocks of data between buffer pool and FS.
- Attempts to handle **file access error** problems.

Typical DBMS file management subsystems build **on top of OS file operations**.

## DBMS File Organization
Different DBMS make different choices when arranging DB objects in the FS. Examples:
- By-pass the FS and use a raw disk partition.
- Have a single very large file containing all DB data.
- Have several large files, with tables spread across them.
- Have multiple data files, one for each table.
- Have multiple files for each table.
- Etc.

## Single-file DBMS (E.g. SQLite)
Objects are are allocated to **regions (segments) of the file**. If an object grows too large for allocated segment, allocate an **extension**.

Allocating space in Unix files is easy:
- Seek to the place you want and write the data.
- If nothing there already, data is appended to the file.
- If something there already, it gets overwritten.

If seek goes way beyond end of file:
- Unix does not (yet) allocate disk space for the "hole".
- Allocate disk storage only when data is written there.

### Example Layout
![](http://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/files/Pics/storage/single-file-example.png)

```c
SpaceMap = [ (0,10,U), (10,10,U), (20,600,U), (620,100,U), (720,20,F) ]
TableMap = [ ("employee",20,500), ("project",620,40) ]
```

### Pages
Each file segment consists of a number of **fixed-size blocks**. 

```c
#define PAGESIZE 2048 // bytes per page
typdef long PageId; // block index, pageOffset = PageId * PAGESIZE
typedef char *Page; // pointer to page/block buffer
```

### Possible Data Structures For Opened DBs and Tables
```c
typedef struct DBrec {
    char *dbname; // copy of db name
    int fd; // database file
    SpaceMap map; // map of free/used areas
    TableMap names; // map names to areas + sizes
} *DB;

typedef struct Relrec {
    char *relname; // copy of table name
    int start; // page index of start of table data
    int npages; // number of pages of table data
    ...
} *Rel;
```

### Scanning a Relation
```sql
select name from Employee
```

may be implemented as

```c
DB db = openDatabase("myDB");
Rel r = openRelation(db, "Employee");
Page buffer = malloc(PAGESIZE * sizeof(char));

for (int i = 0; i < r->npages; i++) {
    PageId pid = r->start + i;
    get_page(db, pid, buffer);

    for (each tuple in buffer) {
        get tuple data and extract name
        add name to result tuples
    }
}

// start using DB, buffer meta-data.
DB openDatabase(char *name) {
    DB db = new(struct DBrec);
    db->dbname = strdup(name);
    db->fd = open(name, O_RDWR);
    db->map = readSpaceTable(db->fd);
    db->names = readNameTable(db->fd);
    return db;
}

// stop using DB and update all meta-data.
void closeDatabase(DB db) {
    writeSpaceTable(db->fd, db->map);
    writeNameTable(db->fd, db->map);
    fsync(db->fb);
    free(db->dbname);
    free(db);
}

// set up struct describing relation.
Rel openRelation(DB db, char *rname) {
    Rel r = new(struct Relrec);
    r->relname = strdup(rname);
    // get relation data from map tables
    r->start = ...;
    r->npages = ...;
    return r;
}

// stop using a relation.
void closeRelation(Rel r) {
    free(r->relname);
    free(r);
}

// assume that Page = byte[PageSize].
// assume that PageId = block number in file.

// read page from file into memory buffer. 
void get_page(DB db, PageId p, Page buf) {
    lseek(db->fd, p * PAGESIZE, SEEK_SET);
    read(db->fd, buf, PAGESIZE);
}

// write page from memory buffer to file
void put_page(DB db, PageId p, Page buf) {
    lseek(db->fd, p * PAGESIZE, SEEK_SET);
    write(db->fd, buf, PAGESIZE);
}

// managing contents of space mapping table can be complex
// assume an array of (offset, length, status) records.
// allocate n new pages
PageId allocate_pages(int n) {
    if (no existing free chunks are large enough) {
        int endfile = lseek(db->fd, 0, SEEK_END);
        addNewEntry(db->map, endfile, n);
    } else {
        grab "worst fit" chunk
        split off unused section as new chunk
    }
}

// similar complexity for freeing chunks
// drop n pages starting from p
void deallocate_pages(PageId p, int n) {
    if (no adjacent free chunks) {
        markUnused(db->map, p, n);
    } else {
        merge adjacent free chunks
         compress mapping table
    }

    // note that file itself is not changed
    // changes take effect when closeDatabase() executed
}
```

## Multiple-file Disk Manager
Most DBMSs don't use a single large file for all data. They typically provide:
- **Multiple files** partitioned physically or logically.
- Mapping from **DB-level objects to files** (e.g. via catalog meta-data).

Precise file structure varies between DBMSs. 

Using multiple files (one file per relation) can be easier, e.g.
- Adding a new relation.
- Extending the size of a relation.
- Computing page offsets within a relation.

### Example Layout
![](http://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/files/Pics/storage/single-vs-multi.png)

### Structure of PageId
If system uses one file per table:
```c
struct PageId {
    long relid; // relation identifier, can be mapped to filename
    long pagenum; // to identify page within file
} *PageId;
```

If system uses several files per page:
```c
struct PageId {
    long relid; // relation identifier
    long fileid; // combined with relid, gives filename
    long pagenum; // to identify page within file
} *PageId; 
```

## DBMS File Parameters
![](
[Diagram:Pics/file-struct/file-struct0.png])

Typical DBMS/table parameter values

|Quantity|Symbol|Example Value|
|----|----|----|
|Total # tuples|``r``|10^6|
|Record size|``R``|128 bytes|
|Total # pages|``b``|10^5|
|Page size|``B``|8192 bytes|
|# tuples per page|``c``|60|
|Page read/write time|``T_r, T_w``|10 msec|
|Cost to process one page in memory||~=0|