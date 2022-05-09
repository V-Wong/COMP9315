# SIMC Indexing
## Overview
In a SIMC indexing scheme:
- Tuple descriptor formed by **overlaying attribute codewords**.
- Each codeword is ``m``-bits long and has ``k``-bits set to 1.

A **tuple descriptor** ``desc(t)`` is:
- A bit-string, ``m``-bits long, where ``j <= nk`` bits are set to 1.
- ``desc(t) = cw(A_1) OR cw(A_2) OR .. OR cw(A_n)``.

```py
def generateSignature(attributes: List[Attribute], m: int, k: int) -> bits:
    desc: bits = 0
    numAttributes: int = len(attributes)

    for i in range(numAttributes):
        cw: bits = codeword(attributes[i], m, k)
        desc = desc | cw
```

## Queries
To answer query ``q`` in SIMC:
1. Generate ``desc(q)`` by OR-ing codewords for **known attributes**.
    - Unknown attributes will not contribute to descriptor.
2. Attempt to match ``desc(q)`` against all signatures in signature file.

```py
def matches(sig: bits, qdesc) -> bool:
    # Ensures all bits set in qdesc are set in sig.
    # sig is allowed to have additional set bits.
        # Possible because it was an unknown attribute in the query.
        # Or false positive match.
    return (sig & qdesc) == qdesc

def query(r: Rel, q: Query):
    pagesToCheck = set()

    for descriptor in r.signatureFile():
        if matches(descriptor, desc(q)):
            pid = pageOf(tupleID(descriptor))
            pagesToCheck = pagesToCheck.union(pid)

    # scan b_sq = b+q + δ pages to check for matches.
```

## SIMC Parameters
Let ``p_F`` denote the likelihood of a **false match**.

Ways to **reduce false matches**:
- Use **different hash function for each attribute** (``h_i`` for ``A_i``).
- **Increase descriptor size** (``m``).
    - Tradeoff: larger ``m`` means larger signature file ==> read more signature data. 
- Choose ``k`` so that ~=** half of bits are set**.
    - Tradeoff:
        - High ``k`` ==> increased overlapping.
        - Low ``k`` ==> increased hash collisions.

### Choosing Optimal ``m`` and ``k``
1. Start by choosing acceptable ``p_F``.
2. Follow these formulas:
    - ``k = 1/ln(2) * ln(1/p_F)``.
    - ``m = (1/ln(2))^2 * n * ln(1/p_F)``.

## Query Cost for SIMC
Cost to answer PMR query: ``Cost_pmr = b_d + b_sq``.
- Read ``r`` descriptors on ``b_D`` descriptor pages.
- Then read ``b_sq`` data pages for matches. 

``b_D = ceil(r / c_D)`` where ``c_D = floor(B / ceil(m / 8))``.
- Recall: 
    - ``r`` is total number of tuples.
    - ``c_D`` is capacity of signatures per page.

``b_sq`` includes pages with ``r_q`` **matching tuples** and ``r_F`` **false matches**.
- Expected false matches = ``r_F = (r - r_q) * p_F ~= r * p_F`` if ``r_q << r``.
- Example:
    - Worst: ``b_sq = r_q + r_f``.
        - All **matching tuples on different pages** and all **false matches on different pages**.
    - Best: ``b_sq = 1``.
    - Average: ``b_sq = ceil(b(r_q + r_f) / r)``.

## Page-level SIMC
Alternative SIMC approach: **one descriptor for each data page**.
- Every attribute of every tuple in page contributes to descriptor.
- Potentially more efficient.

Size of page descriptor (PD):
- Use previous formulas for ``m`` and ``k`` but **multiply by number of tuples per page**.

File organisation:
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/sig-simc/Pics/select/simc-2level.png)
- Note: each signature now corresponds to a page of tuples.

### PMR Query Algorithm
```py
def query(r: Rel, q: Query) -> List[Tuple]:
    pagesToCheck = set()

    for i in range(len(r.signatureFile())):
        descriptor = r.signatureFile()[i]

        if matches(descriptor[i], desc(q)):
            pid = i
            pagesToCheck = pagesToCheck.union(pid)

    # read and scan b_sq data pages
    for pid in pagesToCheck:
        # check matching tuples.
    
    return # matching tuples
```

## Bit-sliced SIMC
Improvement: store ``b`` ``m``-bit page descriptors as ``m`` ``b``-bit **bit-slices**.

![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/sig-simc/Pics/select/bit-sliced.png)

### PMR Query Algorithm
```
matches = ~0 // all ones
// scan m r-bit slices
for each bit i set to 1 in desc(q) {
   slice = fetch bit-slice i
   matches = matches & slice
}
for each bit i set to 1 in matches {
   fetch page i
   scan page for matching records
}
```

Effective because ``desc(q)`` typically has less than half bits set to 1.

## Comparison of Approaches
**Tuple-based:**
- ``r`` signatures, ``m``-bit signatures, ``k`` bits per attribute.
- Read all pages of signature file in filtering for a query.

**Page-based:**
- ``b`` signatures, ``m_p``-bit signatures, ``k`` bits per attribute.
- Read all pages of signature file in filtering for a query.

**Bit-sliced:**
- ``m``-signatures, ``b``-bit slices, ``k`` bits per attribute.
- Read less than half of the signature file in filtering for a query.

All signature files are roughly the same size, for a given ``p_F``.

