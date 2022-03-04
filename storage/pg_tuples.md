# PostgreSQL Tuples
## Implementation Overview
Main functions:
- ``HeapTuple heap_form_tuple(desc, values[], isnull[])``.
- ``heap_deform_tuple(tuple, desc, values[])``.

PostgreSQL implements tuples via:
- A **contiguous** chunk of memory.
- Starting with a **header** giving e.g. number of fields, nulls, etc.
- Followed by data values (as a sequence of ``Datum``).

## Implementation Structs
### Stored Tuple Information (``HeapTupleData``)
![](https://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/pg-tuples/Pics/storage/heap-tuple.png)

```c
typedef HeapTupleData *HeapTuple;

typedef struct HeapTupleData
{
  uint32           t_len;  // length of *t_data 
  ItemPointerData t_self;  // SelfItemPointer 
  Oid         t_tableOid;  // table the tuple came from 
  HeapTupleHeader t_data;  // -> tuple header and data 
} HeapTupleData;
```

``HeapTupleHeader`` is a **pointer** to a location in a buffer.

### Header and Record Data (``HeapTupleHeader``)
![](https://cgi.cse.unsw.edu.au/~cs9315/22T1/lectures/pg-tuples/Pics/storage/pg-tuple-struct.png)

```c
ypedef HeapTupleHeaderData *HeapTupleHeader;

typedef struct HeapTupleHeaderData // simplified
{
  HeapTupleFields t_heap;
  ItemPointerData t_ctid;      // TID of newer version
  uint16          t_infomask2; // #attributes + flags
  uint16          t_infomask;  // flags e.g. has_null
  uint8           t_hoff;      // sizeof header incl. t_bits
  // above is fixed size (23 bytes) for all heap tuples
  bits8           t_bits[1];   // bitmap of NULLs, var.len.
  // OID goes here if HEAP_HASOID is set in t_infomask
  // actual data follows at end of struct
} HeapTupleHeaderData;
```

### Schema-information for ``Tuple``s
```c
// Schema-related information for HeapTuples.
typedef struct tupleDesc 
{
  int         natts;       // # attributes in tuple 
  Oid         tdtypeid;    // composite type ID for tuple type 
  int32       tdtypmod;    // typmod for tuple type 
  bool        tdhasoid;    // does tuple have oid attribute? 
  int         tdrefcount;  // reference count (-1 if not counting)
  TupleConstr *constr;     // constraints, or NULL if none 
  FormData_pg_attribute attrs[];
  // attrs[N] is a pointer to description of attribute N+1 
} *TupleDesc;
```

### Schema-formation for One ``Tuple``
```c
// Schema-related information for one attribute.
typedef struct FormData_pg_attribute
{
  Oid      attrelid;    // OID of reln containing attr
  NameData attname;     // name of attribute
  Oid      atttypid;    // OID of attribute's data type
  int16    attlen;      // attribute length
  int32    attndims;    // # dimensions if array type
  bool     attnotnull;  // can attribute have NULL value
  .....                 // and many other fields
} FormData_pg_attribute;
```

### Attribute Values ``Datum``
Attribute values are packaged as ``Datum``s:
```c
typdef uintptr_t Datum;
```

The **actual data value**:
- May be stored in the ``Datum`` (e.g. ``int``).
- May have a header with length (for variable length attribute).
- May be stored in a TOAST file (if large value).

Attribute values can be **extracted** as ``Datum`` from ``HeapTuple``s:

```c
Datum heap_getattr(
      HeapTuple tup,     // tuple (in memory)
      int attnum,        // which attribute
      TupleDesc tupDesc, // field descriptors
      bool *isnull       // flag to record NULL
)
```

values of ``Datum`` objects can be manipulated via e.g.

```c
// DatumGetBool:
//   Returns boolean value of a Datum.

#define DatumGetBool(X) ((bool) ((X) != 0))

// BoolGetDatum:
//   Returns Datum representation for a boolean.

#define BoolGetDatum(X) ((Datum) ((X) ? 1 : 0))
```