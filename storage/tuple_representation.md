# Tuple Representation
## Records vs Tuples
**Tables** are defined by a **schema**, e.g..

```sql
create table Employee (
   id   integer primary key,
   name varchar(20) not null,
   job  varchar(10), 
   dept smallint references Dept(id)
);
```

**Tuples** are collection of attribute values based on a schema. **Records** are a sequence of bytes, containing data for one tuple. Bytes need to be **interpreted relative to a schema** to get a tuple.

## Converting Records to Tuples
![](http://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/tuples/Pics/storage/rec-to-tuple.png)

A ``Record`` is an array of bytes.
    - Represents the data values from a **typed** ``Tuple``.
    - Stored on disk (persistent) or in a memory buffer.

A ``Tuple`` is a collection of named, typed values (similar to C structs).
    - An **interpretable structure** is needed to manipulate the values.
    - Stored in working memory (temporary).

### Information to Interpret Bytes in a Record
- May be contained in schema data in DBMS catalog.
- May be stored in page directory.
- May be stored in the record (header).
- May be stored partly in record and partly in schema.

For variable-length records, formatting information is required:
- Must be stored in the record or in the page directory.
    - Since it refers to individual records and not the whole table.
- At the least, need to know how many bytes in each variable length value.

## Operations on Records
Access record via ``RecordId``:
```c
Record get_record(Relation rel, RecordId rid) {
    (pid, tid) = rid;
    Page buf = get_page(rel, pid);
    return get_bytes(rel, buf, tid);
}
```

Cannot use a ``Record`` directly; need a ``Tuple``:
```c
Relation rel = ... // relation schema
Record rec = get_record(rel, rid);
Tuple t = makeTuple(rel, rec);
```

Once we have a ``Tuple``, we can access individual attributes/fields (with index).
```c
int x = getIntField(t, 1);
char *s = getStrField(t, 2);
```

## Fixed Length Records
Possible encoding scheme:
- Record format (length + offsets) stored in catalog.
- Data values stored in fixed-size slots in data pages.

![](http://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/tuples/Pics/storage/fixed-length.png)

## Variable Length Records
Possible encoding scheme:
- Prefix each field by length.
    - ![](http://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/tuples/Pics/storage/rec1.png)
- Terminate fields by delimiter.
    - ![](http://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/tuples/Pics/storage/rec2.png)
    - Note: similar to C strings.
- Array of offsets.
    - ![](http://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/tuples/Pics/storage/rec3.png)

## Data Types
DBMSs typically define a fixed set of base types which have a corresponding implementation-level data type for field values:

|DBMS Type|C Level Type|
|---|----|
|``DATE``|``time_t``|
|``FLOAT``|``float, double``|
|``INTEGER``|``int, long``|
|``NUMBER(n)``|``int[]``|
|``VARCHAR(n)``|``char[]``|

## Field Descriptors
``Tuple`` can be implemented as:
- List of field descriptors for a record instance.
    - Where ``FieldDesc`` gives ``(offset, length, type)`` information.
- Along with a reference to the ``Record`` data.

```c
typedef struct {
  ushort    nfields;   // number of fields/attrs
  ushort    data_off;  // offset in struct for data
  FieldDesc fields[];  // field descriptions
  Record    data;      // pointer to record in buffer
} Tuple;
```

Fields are derived from relation descriptor + record instance data.

``Tuple`` **data** could be:
- A pointer to bytes stored elsewhere in memory.
    - ![](http://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/tuples/Pics/storage/rec8.png)
- Or, appended to ``Tuple struct`` (used widely in PostgreSQL).
    - ![](http://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/tuples/Pics/storage/rec9.png)