# Multi-dimensional Tree Indexes
## Overview
Suppose we have the tuples:

```
R('a',1)  R('a',5)  R('b',2)  R('d',1)
R('d',2)  R('d',4)  R('d',8)  R('g',3)
R('j',7)  R('m',1)  R('r',5)  R('z',9)
```

The tuple-space for the tuples is given by:

![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/nd-trees/Pics/select/2d-space.png)

Different multi-dimensional search trees **partition the tuple-space** in different ways.

## kd-Trees
kd-trees are multi-way search trees where:
- **Each level** of the tree partitions on a **different attribute**.
- Each node contains ``n - 1`` key values, points to ``n`` subtrees.

Example partitioning:
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/nd-trees/Pics/select/kd-tree-space.png)

Corresponding tree:
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/nd-trees/Pics/select/kd-tree.png)

Note: tree in image is binary and hence has ``n = 2``.

### Searching in kd-Trees
```py
def search(q: Query, r: Relation, l: Level, n: Node) -> Node:
    if isDataPage(n):
        buf = getPage(fileOf(R), idOf(n)):
        # check buf for matching tuples
        # return matching tuples
    else:
        a = attributeLevel[l]
        if not hasValue(q, a)
            nextNodes = # all children of n
        else:
            val = getAttribute(q, a)
            nextNodes = find(n, q, a, val)

        for child in nextNodes:
            search(q, r, l + 1, child)
```

## Quad Trees
Quad trees use regular, **disjoint partitioning** of tuple space:
- For 2d, partition space into **quadrants** (NW, NE, SW, SE).
- Each quadrant can be further subdivided into four, etc.

Example partitioning:
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/nd-trees/Pics/select/quad-tree-space.png)

Corresponding tree:
![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/nd-trees/Pics/select/quad-tree-space.png)

Basis for partitioning:
- Quadrant that has no sub-partitions is a **leaf quadrant**.
- **Each leaf** quadrant maps to a **single data page**.
- Subdivide until points in each quadrant fit into one data page.
- Ideal: same number of points in each leaf quadrant (balanced).
- **Point density varies** over space.
    - Different regions require **different levels of partitioning**.
- Means tree is **not necessarily balanced**.

### Searching in Quad Trees
1. Find all regions in current node that query overlaps with.
2. For each region, check its node.
    - If node is a leaf, check corresponding page for matches.
    - Else recursively repeat search from current node.

## R-Trees
R-Trees use a flexible, **overlapping partitioning** of tuple space:
- Each node in the tree represents a kd hypercube.
- Its children represent (possibly overlapping) subregions.
- The child regions do not need to cover the entire parent region.

**Overlap** and **partial cover** means:
- Can **optimise space partitioning** wrt. data distribution.
- So that there are **similar number of points in each region**.

Aim: height-balanced, partly-full index pages.

![](https://cgi.cse.unsw.edu.au/~cs9315/21T1/lectures/nd-trees/Pics/select/r-tree.png)

### Insertion into R-tree
Insertion of an object ``R`` occurs as follows:
1. Start at root, look for children that completely contain ``R``.
2. If no child completely contains ``R``, **choose one** of the children and **expand its boundaries** so that it does contain ``R``.
3. If several children contain ``R``, **choose one** and proceed to child.
4. Repeat above containment search in children of current node.
5. Once we reach data page, insert ``R`` if there is room.
6. If no room in data page, replace by two data pages.
7. **Partition** existing objects between two data pages.
8. Update node pointing to data pages.
    - May cause B-tree-like propagation of node changes up into tree.

### Query with R-trees
Designed to handle space queries and "where-am-I" queries.

"Where-am-I" query: **find all regions** containing a given point ``P``:
1. Start at root, select all children whose subregions contain ``P``.
2. If there are zero such regions, search finishes with ``P`` not found.
3. Otherwise, recursively search within node for each subregion.
4. Once we reach a leaf, we know that region contains ``P``.

Space (region) queries are handled in a similar way:
- Traverse down any path that intersects the query region.

## Costs of Search in Multi-d Trees
**Best case:** PMR query where **all attributes have known values**:
- In kd-trees and quad-trees, follow single tree path.
- Cost is equal to depth ``D`` of tree.
- In R-trees, may follow several paths (overlapping partitions).

**Typical case:** some attributes are **unknown** or **defined by range**:
- Need to visit multiple sub-trees.
- How many depends on: range, choice-points in tree nodes.

## Multi-Dimensional Trees in PostgreSQL
PostgreSQL uses **Generalized Search Trees** (GiST).

GiST indexes parameterise: data type, searching, splitting:
- Via seven user-defined functions.

GiST trees have the following structural constraints:
- Every node is at least fraction ``f`` full (e.g. 0.5).
- The root node has at least two children (unless also a leaf).
- All leaves appear at the same level.