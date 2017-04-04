# Functions to create interval graphs in Julia

export IntervalGraph, IntervalDigraph1, IntervalDigraph2
export RandomIntervalGraph, RandomIntervalDigraph1, RandomIntervalDigraph2
export UnitIntervalGraph, RandomUnitIntervalGraph
export UnitIntervalGraphEvolution

"""
`IntervalGraph(Jlist)` creates an interval graph from a list of closed
intervals.
"""
function IntervalGraph{T}(Jlist::Array{ClosedInterval{T},1})
  d = Dict{Int,ClosedInterval{T}}()
  n = length(Jlist)
  for k=1:n
    d[k] = Jlist[k]
  end
  return IntervalGraph(d)
end


"""
`IntervalGraph(f::Dict)` creates asn interval graph from a dictionary
whose keys are the names of the vertices and whose values are
intervals.
"""
function IntervalGraph{K,T}(f::Dict{K,ClosedInterval{T}})
    klist = collect(keys(f))
    G = SimpleGraph{K}()
    for v in klist
        add!(G,v)
    end

    n = length(klist)

    for i = 1:n-1
        u = klist[i]
        for j = i+1:n
            v = klist[j]
            if !isempty( f[u]*f[v] )
                add!(G,u,v)
            end
        end
    end
    cache_save(G,:IntervalRepresentation,f)
    return G
end



"""
`edge_helper(A,B)` for closed intervals `A` and `B` is a private
function that returns the following values:

+ `0` if no edge
+ `1` if edge from `A` to `B` (but not reverse)
+ `2` if edge from `B` to `A` (but not reverse)
+ `3` if both
"""
function edge_helper(A::ClosedInterval, B::ClosedInterval)
    # no intersection
    if isempty(A*B)
        return 0
    end

    # containment
    if (left(A) <= left(B) <= right(A)) && (left(A) <= right(B) <= right(A))
        return 3
    end

    if (left(B) <= left(A) <= right(B)) && (left(B) <= right(A) <= right(B))
        return 3
    end

    # overlap
    if left(A) <= left(B)
        return 1
    end
    return 2
end


"""
`IntervalDigraph1(Jlist)` creates a type I interval digraph from a
list of closed intervals.
"""
function IntervalDigraph1{T}(Jlist::Array{ClosedInterval{T},1})
    n = length(Jlist)
    G = IntDigraph(n)
    for u=1:n
        J = Jlist[u]
        for v=u:n
            K = Jlist[v]

            choice = edge_helper(J,K)

            if choice == 1 || choice == 3
                add!(G,u,v)
            end

            if choice == 2 || choice == 3
                add!(G,v,u)
            end

        end
    end
    return G
end


"""
`IntervalDigraph2(send_list, rec_list)` creates a Type II interval
graph from two lists of intervals.
"""
function IntervalDigraph2{T}(
         send_list::Array{ClosedInterval{T},1},
         rec_list::Array{ClosedInterval{T},1}
                            )
    n = length(send_list)
    if length(rec_list) != n
        error("send_list and rec_list must be same length")
    end

    G = IntDigraph(n)

    for u=1:n
        A = send_list[u]
        for v=1:n
            B = rec_list[v]
            if !isempty(A*B)
                add!(G,u,v)
            end
        end
    end
    return G
end



"""
`IntervalDigraph(f::Dict)` creates a type I interval digraph from a
dictionary whose keys are the names of the vertices and whose values
are intervals.
"""
function IntervalDigraph1{K,T}(snd::Dict{K,ClosedInterval{T}} ,
                              rec::Dict{K,ClosedInterval{T}})
    if length(snd) != length(rec)
        error("send and receive dictionaries must have same keys")
    end

    klist = keys(snd)
    for k in klist
        if !haskey(rec)
            error("send and receive dictionaries must have same keys")
        end
    end

    n = length(klist)
    G = SimpleDigraph{K}()

    for i=1:n
        u = klist[i]
        A = snd[u]
        for j=1:n
            v = klist[j]
            B = rec[v]

            choice = edge_helper(A,B)

            if choice == 1 || choice == 3
                add!(G,u,v)
            end

            if choice == 2 || choice == 3
                add!(G,v,u)
            end
        end
    end
    return G
end



"""
`IntervalDigraph2(send::Dict,rec::Dict)` creates a Type II interval
digraph from two dictionaries mapping vertices to intervals.
"""
function IntervalDigraph2{K,T}(snd::Dict{K,ClosedInterval{T}} ,
                              rec::Dict{K,ClosedInterval{T}})
    if length(snd) != length(rec)
        error("send and receive dictionaries must have same keys")
    end

    klist = keys(snd)
    for k in klist
        if !haskey(rec)
            error("send and receive dictionaries must have same keys")
        end
    end

    n = length(klist)
    G = SimpleGraph{K}()

    for i=1:n
        u = klist[i]
        A = snd[u]
        for j=1:n
            v = klist[j]
            B = rec[v]
            if !isempty(A*B)
                add!(G,u,v)
            end
        end
    end

    return G
end


"""
`RandomIntervalGraph(n)` generates a random interval graph with `n`
vertices.
"""
function RandomIntervalGraph(n::Int)
    Jlist = [ ClosedInterval(rand(),rand()) for _ in 1:n ]
    return IntervalGraph(Jlist)
end


"""
`RandomIntervalDigraph1(n)` generates a random type I interval
digraph with `n` vertices.
"""
function RandomIntervalDigraph1(n::Int)
    Jlist = [ ClosedInterval(rand(),rand()) for _ in 1:n ]
    return IntervalDigraph1(Jlist)
end




"""
`RandomIntervalDigraph2(n::Int)` generates a random type II
directed interval graph with `n` vertices.
"""

function RandomIntervalDigraph2(n::Int)
    snd_list = [ ClosedInterval(rand(),rand()) for _ in 1:n ]
    rec_list  = [ ClosedInterval(rand(),rand()) for _ in 1:n ]
    return IntervalDigraph2(snd_list, rec_list)
end



"""
`UnitIntervalGraph(x,t=1)` creates a unit interval graph where the
vector `x` specifies the left end points of the intervals. The
optional parameter `t` specifies the lengths of the intervals.
"""
function UnitIntervalGraph{T<:Real}(points::Vector{T}, t::Real=1)
    n = length(points)
    G = IntGraph(n)
    for u=1:n-1
        x = points[u]
        for v=u+1:n
            y = points[v]
            if abs(x-y) <= t
                add!(G,u,v)
            end
        end
    end
  return G
end

"""
`UnitIntervalGraph(f,t=1)` creates a unit interval graph from a
dictionary mapping vertex names to the left end points of their
intervals. The optional parameter `t` specifies the length of the
intervals.
"""
function UnitIntervalGraph{S,T<:Real}(f::Dict{S,T}, t::Real=1)
    vtcs = collect(keys(f))
    n = length(vtcs)
    G = SimpleGraph{S}()
    for v in vtcs
        add!(G,v)
    end

    for i=1:n-1
        u=vtcs[i]
        for j=i+1:n
            v=vtcs[j]
            if abs(f[u]-f[v]) <= t
                add!(G,u,v)
            end
        end
    end
    return G
end

"""
`RandomUnitIntervalGraph(n,t)` creates a unit interval graph with `n`
vertices whose left end points are chosen iid uniformly from [0,1] and
whose lengths are all given by `t` (default value 0.5).
"""
function RandomUnitIntervalGraph(n::Int, t::Real=0.5)
    x = rand(n)
    return UnitIntervalGraph(x,t)
end

"""
`UnitIntervalGraphEvolution(points)` gives the sequence of edges as
the lengths of the intervals (whose left end points are specified in
`points`) increases.

This returns a pair consisting of the sequence of edges and the
lengths at which those edges appear.
"""

function UnitIntervalGraphEvolution{S<:Real}(points::Vector{S})
    n = length(points)
    nC2 = round(Int,n*(n-1)/2)

    edges = Vector{Tuple{Int,Int}}(nC2)
    diffs = Vector{S}(nC2)

    idx = 0

    for i=1:n-1
        for j=i+1:n
            idx += 1
            edges[idx] = (i,j)
            diffs[idx] = abs(points[i] - points[j])
        end
    end

    p = sortperm(diffs)

    return (edges[p], diffs[p])

end

"""
`UnitIntervalGraphEvolution(n::Int)` is equivalent to
`UnitIntervalGraphEvolution(sort(rand(n)))`.
"""
UnitIntervalGraphEvolution(n::Int)=
    UnitIntervalGraphEvolution(sort(rand(n)))
