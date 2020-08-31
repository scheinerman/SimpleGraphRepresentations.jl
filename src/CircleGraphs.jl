export CircleGraph, RandomCircleGraph, RandomCircleRepresentation
export isCircleGraph

"""
`list2locs(list)` takes a list of values as input. Every item on the list
should appear exactly twice. This function returns a dictionary mapping
items on the list to a pair of positive integers giving the two locations
of that element in the list. It's a helper function used by
`CircleGraph`.
"""
function list2locs(list::Array{T,1}) where {T}
    # build a map giving the locations of each symbol on the list
    err_msg = "Invalid input list"
    # check that the list length is even
    n = length(list)
    if n % 2 == 1
        error(err_msg)
    end

    positions = Dict{T,Vector{Int}}()

    for i = 1:n
        elt::T = list[i]
        if haskey(positions, elt)  # already have 1st position
            if positions[elt][2] > 0  # and already have 2nd; that's bad
                error(err_msg)
            else
                positions[elt][2] = i
            end
        else # never seen this element before
            positions[elt] = [i, 0]
        end
    end
    return positions
end

"""
`CircleGraph(list)` takes a list of elements and creates a circle
graph from them. Every element on the list should appear exactly
twice on the list, or else an error is thrown.
"""
function CircleGraph(list::Array{T,1}) where {T}
    positions = list2locs(list)

    elts = collect(keys(positions))
    n = length(elts)

    G = SimpleGraph{T}()
    for v in elts
        add!(G, v)
    end

    for i = 1:n-1
        v = elts[i]
        a = positions[v]
        for j = i+1:n
            w = elts[j]
            b = positions[w]
            if a[1] < b[1] < a[2] < b[2] || b[1] < a[1] < b[2] < a[2]
                add!(G, v, w)
            end
        end
    end

    cache_save(G, :CircleRepresentation, list)
    cache_save(G, :name, "Circle graph")
    return G
end

"""
`CircleGraph(str::String)` creates a circle graph from
a string of ASCII characters; each character must appear exactly
twice in the string.
"""
function CircleGraph(str::String)
    list = [ch for ch in str]
    return CircleGraph(list)
end

"""
`RandomCircleRepresentation(n)` returns a `2n` long list
consisting of the numbers `1:n` each exacty twice in some
random order.
"""
function RandomCircleRepresentation(n::Int)
    list = [collect(1:n); collect(1:n)]
    p = randperm(2n)
    return list[p]
end

"""
`RandomCircleGraph(n)` creates a random circle graph with `n`
vertices.
"""
function RandomCircleGraph(n::Int)
    return CircleGraph(RandomCircleRepresentation(n))
end


# This code by Tara


# returns true if G is a circle graph, false otherwise

using SimpleGF2

"""
`isCircleGraph(G)` returns `true` if `G` is a circle graph
and `false` otherwise.
"""
function isCircleGraph(G::SimpleGraphs.SimpleGraph)
    V = eltype(G)
    vertNum = Dict{V,Int}()
    counter = 1
    verts = length(vlist(G))
    z = zeros(GF2, verts * verts + 1)
    C = deepcopy(z)
    vertices = vlist(G)
    for v in vertices
        vertNum[v] = counter
        counter = counter + 1
    end
    for e in elist(G)
        x = deepcopy(z)
        x[(vertNum[e[1]]-1)*verts+vertNum[e[2]]] = 1
        x[(vertNum[e[2]]-1)*verts+vertNum[e[1]]] = 1
        x[verts*verts+1] = 1
        C = hcat(C, x)
    end
    n = length(vertices)
    for v in vertices
        for i = 1:n
            for j = 1+i:n
                v1 = vertices[i]
                v2 = vertices[j]
                if (has(G, v, v1) && !has(G, v, v2)) ||
                   (has(G, v, v2) && !has(G, v, v1)) ||
                   v == v1 ||
                   v == v2 ||
                   v1 == v2
                    continue
                elseif has(G, v, v1) && has(G, v, v2)
                    if !has(G, v1, v2)
                        x = deepcopy(z)
                        x[(vertNum[v]-1)*verts+vertNum[v1]] = 1
                        x[(vertNum[v]-1)*verts+vertNum[v2]] = 1
                        x[(vertNum[v1]-1)*verts+vertNum[v2]] = 1
                        x[(vertNum[v2]-1)*verts+vertNum[v1]] = 1
                        x[verts*verts+1] = 1
                        C = hcat(C, x)
                    end
                elseif !has(G, v, v1) && !has(G, v, v2)
                    if has(G, v1, v2)
                        x = deepcopy(z)
                        x[(vertNum[v]-1)*verts+vertNum[v1]] = 1
                        x[(vertNum[v]-1)*verts+vertNum[v2]] = 1
                        C = hcat(C, x)
                    end
                end
            end
        end
    end
    C = C'
    try
        solve_augmented(C)
    catch
        return false
    end
    return true
end
