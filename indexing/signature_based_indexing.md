# Signature-based Indexing
## Indexing with Signatures
**Signature** based indexing:
- Designed for **PMR queries**.
- Does not try to achieve better than O(n) performance.
- Attempts to provide **efficient linear search**.

**Each tuple** is associated with a **signature**:
- A compact **lossy descriptor for the tuple**.
- Formed by **combining information from multiple attributes**.
- Stored in a **signature file**, parallel to data file.

**Pre-filtering** is done via signatures.

## File Organisation with Signatures
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/signatures/Pics/select/sigfile1.png)

One signature slot per tuple slot; unused signature slots are zeroed.

Signatures do NOT determine record placement.
- Can use with **other indexing**.

## Signatures
Signatures **summarises** the data from a tuple.

A tuple consists of ``n`` attribute values ``A_1, ... A_n``.

A **codeword** ``cw(A_i)`` is:
- A bit-string, ``m`` bits long, where ``k`` bits are set to 1 (``k << m``).
- Derived from the value of a single attribute ``A_i``.

A **tuple descriptor** (signature) is built
- By combining ``cw(A_i)`` for ``i = 1..=n``.
- Aim to have roughly half of the bits set to 1.

## Generating Codewords
```py
def codeword(attribute_value: bytes, m: int, k: int) -> bits:
    numBits: int = 0
    codeword: bits = 0

    seed_random(hash(attr_value))
    while numBits < k:
        i = random() % m
        if ((1 << i) & codeword) == 0:
            codeword |= 1 << i
            numBits += 1

    return codeword # m-bits with k 1-bits and m-k 0-bits.
```

### Superimposed Codewords (SIMC)
In a SIMC indexing scheme, tuple descriptors are formed by **overlaying attribute codewords** (bitwise-or).

![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/signatures/Pics/select/simc-sig.png)

A SIMC tuple descriptor ``desc(t)`` is:
- ``m`` bit long bit string, where ``j <= nk`` bits are set to 1.
- ``desc(t) = cw(A_1) OR cw(A_2) OR ... OR cw(A_n)``

### Concatenated Codewords (CATC)
In a CATC indexing scheme, tuple descriptors are formed by **concatenating attribute codewords**.

![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/signatures/Pics/select/catc-sig.png)

A CATC tuple descriptor is:
- ``m`` bit long bit string, where ``j = nk`` bits are set to 1.
- ``desc(t) = cw(A_1) + cw(A_2) + ... + cw(A_n)``.

Each codeword is ``p = m / n`` bits long, with ``k = p / 2`` bits set to 1.

## Queries Using Signatures
To answer query ``q`` with a signature based index:
1. Generate a query descriptor ``q``.
2. Scan the signature file using the query descriptor.
3. If ``sig_i`` matches ``desc(q)``, then tuple ``i`` may be a match.

``desc(q)`` is formed from codewords of known attributes. Effectively, any unknown attribute ``A_i`` has ``cw(A_i) = 0``.

## False Matches
Both SIMC and CATC can produce **false matches**:
- ``matches(D[i], desc(q))`` is true, but ``Tup[i]`` is not a solution for ``q``.
- Natural result of hash functions not being injective.

For SIMC, overlaying could also product **unfortunate bit combinations**.
- Need to choose good ``m`` and ``k`` value.

## SIMC vs CATC
Both build ``m``-bit wide signatures with ~1/2 bits set to 1.

Both have codewords with ~``m/(2n)`` bits set to 1.

CATC: codewords are ``m/n`` = ``p``-bits wide.
- Shorter codewords ==> **more hash collisions**.
- Also has option of different length codeword ``p_i`` for each ``A_i`` with ``sum(p_i for i in nattributes) == m``.

SIMC: codewords are also m-bits wide.
- Longer codewords ==> l**ess hash collisions** but also has **overlay collisions**.
