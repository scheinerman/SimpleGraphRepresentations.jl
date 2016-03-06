export PermutationGraph, RandomPermutationGraph

"""
`perm_adj(a,b)` is used to test for adajency in permutation graphs.
This function is not exported.
"""
function perm_adj{S<:Real, T<:Real}(a::Tuple{S,T}, b::Tuple{S,T})
    if a[1] < b[1]
        return a[2] > b[2]
    end
    return a[2] < b[2]
end

"""
`PermutationGraph(p::Permutation,q::Permutation)` builds a permutation
graph based on the permutations `p` and `q`. The vertex set is `1:n`
where `n` is the length of the permutations.
"""
function PermutationGraph(p::Permutation, q::Permutation)
    n = length(p)
    if length(q) != n
        error("Two permutations must be the same length")
    end
    G = IntGraph(n)
    for u=1:n-1
        for v=u+1:n
            if perm_adj( (p[u],q[u]) , (p[v],q[v]) )
                add!(G,u,v)
            end
        end
    end
    return G
end

"""
`PermutationGraph(p::Permutation)` is equivalent to
`PermutationGraph(p,id)` where `id` is the identity permutation.
"""
function PermutationGraph(p::Permutation)
    n = length(p)
    q = Permutation(n)
    return PermutationGraph(p,q)
end

"""
`PermutationGraph(d::Dict)` creates a permutation graph form a
dictionary that maps vertex names to pairs of real numbers.
The vertex type of the resulting graph is the key type of `d`.
The values in `d` must be all `Tuple{S,T}` where `S` and `T` are
subtypes of `Real`. For example, declare `d` like this:
```
d = Dict{ASCIIString, Tuple{Int,Int}}()
```
"""
function PermutationGraph{VV, S<:Real, T<:Real}(d::Dict{VV,Tuple{S,T}})
    vtcs = collect(keys(d))
    G = SimpleGraph{VV}()
    for v in vtcs
        add!(G,v)
    end

    n = length(vtcs)
    for i=1:n-1
        u = vtcs[i]
        for j=i+1:n
            v = vtcs[j]
            if perm_adj(d[u],d[v])
                add!(G,u,v)
            end
        end
    end
    return G
end

"""
`RandomPermutationGraph(n)` creates a random permutation graph with
`n` vertices.
"""
function RandomPermutationGraph(n::Int)
    p = RandomPermutation(n)
    q = RandomPermutation(n)
    return PermutationGraph(p,q)
end
