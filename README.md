# SimpleGraphRepresentations

Extension of `SimpleGraphs` containing methods for dealing with
intersection graphs and the like.

This module requires the following:

+ `SimpleGraphs`
+ `ClosedIntervals`
+ `Permutations`


## Interval Graphs

We provide the following functions for creating interval graphs and
interval digraphs.

### Undirected interval graphs

+ `IntervalGraph(Jlist)` creates an interval graph from a list of
  closed intervals. The vertices are numbered `1` to `n` (where `n` is
  the length of `Jlist`.

+ `IntervalGraph(f)` where `f` is a dictionary mapping vertex names to
  closed intervals creates an interval graph.

+ `RandomIntervalGraph(n)` creates a random `n`-vertex interval graph.

### Directed interval graphs

#### Type I

+ `IntervalDigraph1(Jlist)` creates a type I interval digraph from a
  list of intervals.

+ `IntervalDigraph(f)` where `f` is a dictionary mapping vertex nmaes
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


