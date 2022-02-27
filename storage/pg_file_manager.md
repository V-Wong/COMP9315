# PostgreSQL File Manager
## File Organization
![](http://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pg-files/Pics/storage/pg-file-arch.png)

## Components of Storage Subsystem
- **Mapping** from relations to files (``RelFileNode``).
- **Abstraction** for open relation pool (``storage/smgr``).
- Functions for **managing files** (``storage/smgr/md.c``).
- **File-descriptor pool** (``storage/file``).

PostgreSQL has two basic kinds of files:
- **Heap files** containing data (tuples).
- **Index files** containing index entries.

## Relations as Files
PostgresSQL identifies **relation files via their OIDs**. The core data structure for this is ``RelFileNode``:

```c
typedef struct RelFileNode {
    Oid  spcNode;  // tablespace
    Oid  dbNode;   // database
    Oid  relNode;  // relation
} RelFileNode;
```

Global (shared) tables (e.g. ``pg_database``) have
- ``spcNode == GLOBALTABLESPACE_OID``.
- ``dbNode == 0``.

The ``relpath`` function maps ``RelFileNode`` to file:

```c

char *relpath(RelFileNode r)  // simplified
{
   char *path = malloc(ENOUGH_SPACE);

   if (r.spcNode == GLOBALTABLESPACE_OID) {
      /* Shared system relations live in PGDATA/global */
      Assert(r.dbNode == 0);
      sprintf(path, "%s/global/%u", DataDir, r.relNode);
   }
   else if (r.spcNode == DEFAULTTABLESPACE_OID) {
      /* The default tablespace is PGDATA/base */
      sprintf(path, "%s/base/%u/%u", DataDir, r.dbNode, r.relNode);
   }
   else {
      /* All other tablespaces accessed via symlinks */
      sprintf(path, "%s/pg_tblspc/%u/%u/%u", DataDir, r.spcNode, r.dbNode, r.relNode);
   }
   return path;
}
```

## File Descriptor Pool
Unix has **limits** on number of **concurrently open files**. PostgreSQL maintains a **pool of open file descriptors**:
- To **hide this limitation** from **higher level functions**.
    - Low level implementation may have to start **closing files** after a certain point.
    - When such a file is opened again, the low level implementation must **reopen the file**.
    - This reopening of the file is **not seen by the high level functions**.
        - It assumes the file has remained open the whole time.
        - From the perspective of these high level functions, there is practically no limit to number of open files.
- To **minimize** expensive ``open()`` operations.

File names are simply strings: ``typedef char *FileName``.
Open files are referenced via: ``typedef int File``.
A ``File`` is an index into a table of **"virtual file descriptors"**.
    - NOT a file descriptor.

### File Descriptor Pool Interface
```c
// open a file in the database directory ($PGDATA/base/...)
File FileNameOpenFile(FileName fileName, int fileFlags, int fileMode);
// open temp file; flag: close at end of transaction?
File OpenTemporaryFile(bool interXact);
void FileClose(File file);
void FileUnlink(File file);
int  FileRead(File file, char *buffer, int amount);
int  FileWrite(File file, char *buffer, int amount);
int  FileSync(File file);
long FileSeek(File file, long offset, int whence);
int  FileTruncate(File file, long offset);
```

These are analogous to Unix syscalls ``open()``, ``close()``, ``read()``, ``write()``, ``lseek()``.

### Virtual File Descriptors
Physically stored in **dynamically-allocated array**:
![](http://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pg-files/Pics/storage/vfd-cache1.png)

Also arranged into **linked list by recency-of-use**:
![](http://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pg-files/Pics/storage/vfd-cache2.png)

``VfdCache[0]`` holds list head/tail pointers.

Simplified structure:
```c
typedef struct vfd
{
    s_short  fd;              // current FD, or VFD_CLOSED if none
    u_short  fdstate;         // bitflags for VFD's state
    File     nextFree;        // link to next free VFD, if in freelist
    File     lruMoreRecently; // doubly linked recency-of-use list
    File     lruLessRecently;
    long     seekPos;         // current logical file position
    char     *fileName;       // name of file, or NULL for unused VFD
    // NB: fileName is malloc'd, and must be free'd when closing the VFD
    int      fileFlags;       // open(2) flags for (re)opening the file
    int      fileMode;        // mode to pass to open(2)
} Vfd;
```

## File Manager
PostgreSQL stores each table:
- In the directory ``PGDATA/pg_database.oid``.
- Often in multiple files (aka **forks**).
    - Unix files can not be infinitely large.

![](http://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pg-files/Pics/storage/one-table-files.png)

Data files (``Oid``, ``Oid.1``, ...):
- Sequence of fixed-size blocks/pages (typically 8KB).
- Each page contains tuple data and admin data.
- Max size of data files 1GB (Unix limitation).

![](http://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pg-files/Pics/storage/heap-file.png)

### Maps
Free space map (``Oid_fms``):
- Indicates where free space is in data pages.
- "Free" space is only free after ``VACUUM``.
    - ``DELETE`` simply marks tuples as no longer in use ``xmax``.

Visibility map (``Oid_vm``):
    - Indicates pages where all tuples are "visible" (accessible to all currently active transactions).
    - Such pages can be ignored by ``VACUUM``.

### Magnetic Disk Storage Manager (``storage/smgr/md.c``)
- Manages its own pool of open file descriptors (VFd's).
- May use several Vfd's to access data, if several forks.
- Manages mapping from ``PageID`` to file + offset.

PostgreSQL ``PageID`` values are structured:
```
typedef struct
{
    RelFileNode rnode;    // which relation/file
    ForkNumber  forkNum;  // which fork (of reln)
    BlockNumber blockNum; // which page/block 
} BufferTag;
```

### Accessing Blocks
```c
// pageID set from pg_catalog tables
// buffer obtained from Buffer pool
getBlock(BufferTag pageID, Buffer buf)
{
   Vfd vf;  off_t offset;
   (vf, offset) = findBlock(pageID)
   lseek(vf.fd, offset, SEEK_SET)
   vf.seekPos = offset;
   nread = read(vf.fd, buf, BLOCKSIZE)
   if (nread < BLOCKSIZE) ... we have a problem
}

findBlock(BufferTag pageID) returns (Vfd, off_t)
{
   offset = pageID.blockNum * BLOCKSIZE
   fileName = relpath(pageID.rnode)
   if (pageID.forkNum > 0)
      fileName = fileName+"."+pageID.forkNum
   if (fileName is not in Vfd pool)
      fd = allocate new Vfd for fileName
   else
      fd = use Vfd from pool
   if (pageID.forkNum > 0) {
      offset = offset - (pageID.forkNum*MAXFILESIZE)
   }
   return (fd, offset)
}
```