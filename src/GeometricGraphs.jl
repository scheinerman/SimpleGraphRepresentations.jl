# A geometric graph is one in which vertices are mapped to points and
# two vertices are adjacent if the distance between them is at most 1
# (or a set value).

export GeometricGraph, RandomGeometricGraph

"""
`GeometricGraph(A)` where `A` is an `m` by `n` matrix creates a
geometric graph in which the columns of `A` are the points
representing the vertices `1:n`. Two vertices are adjacent iff the
distance between the points is at most `1` (or an optional second
parameter, `d`).
"""
function GeometricGraph{T<:Real}(A::Array{T,2}, d::Real=1)
    r,n = size(A)
    G = IntGraph(n)
    dd::T = d*d

    for i=1:n-1
        vi = A[:,i]
        for j=i+1:n
            vj = A[:,j]
            dv = vi-vj
            if dot(dv,dv) <= dd
                add!(G,i,j)
            end
        end
    end
    return G
end

"""
`GeometricGraph(f)` where `f` is a `Dict` mapping vertex names to
vectors creates a geometric graph in which two vertices are adjacent
iff distance between their points is at most `1` (or `d` if given as a
second argument).
"""
function GeometricGraph{S,T<:Real}(f::Dict{S,Vector{T}}, d::Real=1)
    G = SimpleGraph{S}()
    vtcs = collect(keys(f))
    for v in vtcs
        add!(G,v)
    end

    dd = d*d
    n = length(vtcs)
    for i=1:n-1
        vi = f[vlist[i]]
        for j=i+1:n
            vj = f[vlist[j]]
            dv = vi-vj
            if dot(dv,dv) <= dd
                add!(G,vlist[i],vlist[j])
            end
        end
    end
    return G
end

"""
`RandomGeometricGraph(n::Int, dim::Int=2, d::Real=1)` creates a random
geometric graph by generating `n` points at random in the unit
`dim`-cube. Vertices are adjacent if their corresponding points are at
distance at most `d`.
"""
function RandomGeometricGraph(n::Int, dim::Int=2, d::Real=1)
    return GeometricGraph(rand(dim,n),d)
end

