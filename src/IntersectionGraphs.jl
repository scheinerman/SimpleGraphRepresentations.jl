export IntersectionGraph

AnySet = Union{Set,BitSet}

"""
`IntersectionGraph(setlist)` creates an intersection graph on vertex set
`1:n` from a list of `n` sets (all of type `Set` or all of type
`IntSet`).
"""
function IntersectionGraph(slist::Vector{T}) where {T<:AnySet}
    n = length(slist)
    f = Dict{Int,T}()
    for k = 1:n
        f[k] = slist[k]
    end
    return IntersectionGraph(f)
end

"""
`IntersectionGraph(f)` creates an intersection graph from the
dictionary `f`. The keys are the vertices and the values are the sets
(all of type `Set` or all of type `IntSet`).
"""
function IntersectionGraph(f::Dict{S,T}) where {S,T<:AnySet}
    G = SimpleGraph{S}()
    for v in keys(f)
        add!(G, v)
    end

    vtcs = vlist(G)
    n = length(vtcs)

    for i = 1:n-1
        u = vtcs[i]
        A = f[u]
        for j = i+1:n
            v = vtcs[j]
            B = f[v]

            if length(intersect(A, B)) > 0
                add!(G, u, v)
            end
        end
    end
    cache_save(G, :IntersectionRepresentation, f)
    cache_save(G, :name, "Intersection graph")
    return G
end
