# Simple Graph Representations

The `SimpleGraphRepresentations` module is an extension of
`SimpleGraphs`. It provides methods for dealing with intersection
graphs and the like.

This module requires the following modules:

+ `SimpleGraphs`
+ `ClosedIntervals`
+ `Permutations`

## Interval graphs

We provide the following functions for creating interval graphs and
interval digraphs.

### Undirected interval graphs

+ `IntervalGraph(Jlist)` creates an interval graph from a list of
  closed intervals. The vertices are numbered `1` to `n` (where `n` is
  the length of `Jlist`).

+ `IntervalGraph(f)` where `f` is a dictionary mapping vertex names to
  closed intervals creates an interval graph.

+ `RandomIntervalGraph(n)` creates a random `n`-vertex interval graph.

### Directed interval graphs

#### Type I

+ `IntervalDigraph1(Jlist)` creates a type I interval digraph from a
  list of intervals.

+ `IntervalDigraph(f)` where `f` is a dictionary mapping vertex names
  to closed intervals creates a type I interval digraph.

+ `RandomIntervalDigraph1(n)` creates a random type I interval digraph
  with `n` vertices.


#### Type II

+ `IntervalDigraph2(snd_list, rec_list)` creates a type II interval
  digraph from two lists of intervals.

+ `IntervalDigraph2(s,r)` creates a type II interval digraph where `s`
  and `r` are dictionaries mapping a set of vertices to closed
  intervals.

+ `RandomIntervalDigraph2(n)` creates an `n`-vertex random type II
  interval digraph.


## Permutation graphs

Create permutation graphs from one or two permutations.

+ `PermutationGraph(p,q)` creates a permutation graph in which there
  is an edge from `u` to `v` iff `(p[u]-p[v])*(q[u]-q[v])<0`.

+ `PermutationGraph(p)` is equivalent to `PermutationGraph(p,id)`
  where `id` is the identity permutation.

+ `RandomPermutationGraph(n)` creates an `n`-vertex random permutation
  graph.


## Threshold graphs

+ `ThresholdGraph(wts)` creates a threshold graph from a list of
  weights. Vertices are named `1:n` where `n=length(wts)`.

+ `ThresholdGraph(f)` creates a threshold graph from a dictionary
  mapping vertex names to weights.

+ `RandomThresholdGraph(n)` creates a random threshold graph with
  vertices named `1:n` with IID uniform [0,1] weights. 

## Intersection graphs

+ `IntersectionGraph(setlist)` creates an intersection graph from a
  list of sets (all of type `Set` or all of type `IntSet`). Vertices
  are named `1:n` where `n` is the length of the list of sets.

+ `IntersectionGraph(f)` creates an intersection graph from a
  dictionary mapping vertex names to sets.
