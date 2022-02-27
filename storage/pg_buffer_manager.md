# PostgreSQL Buffer Manager
## Overview
PostgreSQL buffer manager:
- Provides a **shared pool of memory buffers** for **all backends**.
- **All access methods** get data from disk **via buffer manager**.

Buffers are located in a large region of **shared memory**.

## Buffer Pool
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pg-buffers/Pics/storage/buffer-memory.png)

Consists of:
- ``BufferDescriptors``:
    - Shared fixed array (size ``NBuffers``) of ``BufferDesc``.
- ``BufferBlocks``:
    - Shared fixed array (size ``NBuffers``) of 8KB frames.
- ``Buffer`` = index values in above arrays:
    - Indexes: global buffers ``1..NBuffers``; local buffers negative.

## Important Source Code Files
API files:
- ``include/storage/buf.h``:
    - Basic buffer manager data types (e.g. ``Buffer``).
- ``include/storage/bufmgr.h``:
    - Definitions for buffer manager function interface.
- ``include/storage/buf_internals.h``:
    - Definitions for buffer manager internals (e.g. ``BufferDesc``).

Code: ``backend/storage/buffer/*.c``.
Commentary: ``backend/storage/buffer/README``.

## Buffer Descriptor
```c
typedef struct BufferDesc {
    BufferTag tag; // ID of page contained in buffer
    int buf_id; // buffer's index number (from 0)

    // state, containing flags, refcount and usagecount
    pg_atomic_unity32 state;

    int freeNext; // link in freelist chain
    ...
} BufferDesc;
```

## Clock-sweep Replacement Strategy
PostgreSQL page replacement strategy: **clock-sweep**:
- Treat buffer pool as **circular list** of buffer slots.
- ``NextVictimBuffer`` (NVB): holds index of **next possible evictee**.
- If ``Buf[NVB]`` is pinned down or "popular", leave it.
    - ``usage_count`` implements **"popularity/recency"** measure.
    - Incremented on each access to buffer (up to small limit).
    - Decremented each time considered for eviction.
- Else if ``pin_count == 0 && usage_count == 0``, then grab this buffer.
- Increment ``NextVictimBuffer`` and try again (wrap at end).

Action of clock-sweep:
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/pg-buffers/Pics/storage/clock-sweep.png)

For specialised kinds of access (e.g. sequential scan):
- Clock-sweep is not best replacement strategy.
- Can allocate a private "buffer ring".
- Use this buffer ring with alternative replacement strategy.