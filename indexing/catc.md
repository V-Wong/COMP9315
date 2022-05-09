# CATC Indexing
## Overview
In a CATC indexing scheme:
- Tuple signature formed by **concatenating attribute codewords**.
- Signature is ``m`` bits long, with ~= ``m / 2`` bits set to 1.
- Codeword for ``A_i`` is ``u_i`` bits long and has ~= ``u_i / 2`` bits set to 1.
- Each codeword could be different length, but always ``sum(u_i for i in range(n)) == m``.

A tuple descriptor ``desc(t)`` is:
- ``desc(t) = cw(A_n) + cw(A_n-1) + .. + cw(A_1)``.
- Where ``+`` denotes bit-string concatenation.

## Queries
To answer query ``q`` in CATC:
1. Generate ``desc(q)`` by combining codewords for all attributes.
    - For known ``A_i`` use ``cw(A_i)``; for unknown ``A_i``, use ``cw(A_i)``. 
2. Attempt to match ``desc(q)`` against all signatures in signature file.
    - Match implementation is exactly the same as in SIMC.

## CATC Parameters
Let ``p_F`` denote the likelihood of a **false match**.

Ways to **reduce false matches**:
- Use **different hash function for each attribute** (``h_i`` for ``A_i``).
- **Increase descriptor size** (``m``).

### Choosing Optimal ``m`` and ``u``
1. Start by choosing acceptable ``p_F``.
2. Choose ``m`` according to same formula in SIMC.
3. Choose ``u_i``:
    - Each ``A_i`` has **same** ``u_i``, or
    - Allocate ``u_i`` **based on size of attribute domains**.

## Query Cost for CATC
Exactly the same as in SIMC.

## Variation on CATC
Page-level descriptors:
- Same as in SIMC.

Bit slices:
- Same as in SIMC.

## Comparison with SIMC
Assume same ``m``, ``p_F``, ``n`` for each method:
- CATC has ``u_i``-bit codewords, each has ``~= u_i / 2`` bits set to 1.
- SIMC has ``m``-bit codewords, each has ``k`` bits set to 1.
- Signatures for both have ``m`` bits, with ``~= m / 2`` bits set to 1.
- CATC has flexibility in ``u_i`` but small(er) codewords so more hash collisions.
- SIMC has less hash collisions, but has errors from unfortunate overlays.