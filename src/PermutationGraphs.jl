export PermutationGraph, RandomPermutationGraph
export PermutationRepresentation

"""
`perm_adj(a,b)` is used to test for adajency in permutation graphs.
This function is not exported.
"""
function perm_adj(a::Tuple{S,T}, b::Tuple{S,T}) where {S<:Real,T<:Real}
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
    for u = 1:n-1
        for v = u+1:n
            if perm_adj((p[u], q[u]), (p[v], q[v]))
                add!(G, u, v)
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
    return PermutationGraph(p, q)
end

"""
`PermutationGraph(d::Dict)` creates a permutation graph form a
dictionary that maps vertex names to pairs of real numbers.
The vertex type of the resulting graph is the key type of `d`.
The values in `d` must be all `Tuple{S,T}` where `S` and `T` are
subtypes of `Real`. For example, declare `d` like this:
`d = Dict{String, Tuple{Int,Int}}()`.
"""
function PermutationGraph(d::Dict{VV,Tuple{S,T}}) where {VV,S<:Real,T<:Real}
    vtcs = collect(keys(d))
    G = SimpleGraph{VV}()
    for v in vtcs
        add!(G, v)
    end

    n = length(vtcs)
    for i = 1:n-1
        u = vtcs[i]
        for j = i+1:n
            v = vtcs[j]
            if perm_adj(d[u], d[v])
                add!(G, u, v)
            end
        end
    end
    return G
end


"""
`PermutationGraph(f::Dict,g::Dict)` constructs a permutation graph
from a pair of mappings from a vertex set to real values.
"""
function PermutationGraph(f::Dict{T,R}, g::Dict{T,S}) where {T,R<:Real,S<:Real}
    # mush the two dictionaries into one
    h = Dict{T,Tuple{R,S}}()
    for k in keys(f)
        h[k] = f[k], g[k]
    end

    # invoke previous method
    G = PermutationGraph(h)
    cache_save(G, :PermutationRepresentation, (f, g))
    cache_save(G, :name, "Permutation graph")
    return G
end

"""
`RandomPermutationGraph(n)` creates a random permutation graph with
`n` vertices.
"""
function RandomPermutationGraph(n::Int)
    p = RandomPermutation(n)
    q = RandomPermutation(n)
    return PermutationGraph(p, q)
end


"""
`PermutationRepresentation(G)` returns a pair of dictionaries mapping
the vertices of `G` to integers. This pair of dictionaries form a
permutation representation of `G`. (If `G` is not a permutation graph,
an error is thrown.
"""
function PermutationRepresentation(G::SimpleGraph)
    if cache_check(G, :PermutationRepresentation)
        return cache_recall(G, :PermutationRepresentation)
    end
    A = SimpleDigraph()
    try
        A = transitive_orientation(complement(G))
    catch
        error("This graph does not have a permutation representation")
    end
    G1 = deepcopy(A)
    G2 = transitive_orientation(G)
    for e in elist(G2)
        add!(G1, e[1], e[2])
    end
    T = eltype(G)
    sigma = Dict{T,Int}()
    tau = Dict{T,Int}()
    vs1 = sort(vlist(G1), by = v -> out_deg(G1, v), rev = true)
    i = 1
    for v in vs1
        sigma[v] = i
        i = i + 1
    end
    G3 = deepcopy(A)
    for e in elist(G2)
        add!(G3, e[2], e[1])
    end
    vs2 = sort(vlist(G3), by = v -> out_deg(G3, v), rev = true)
    j = 1
    for v in vs2
        tau[v] = j
        j = j + 1
    end
    cache_save(G, :PermutationRepresentation, (sigma, tau))
    return sigma, tau
end
