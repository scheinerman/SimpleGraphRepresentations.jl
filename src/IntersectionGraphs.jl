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



export IntersectionRepresentation
"""
    IntersectionRepresentation(G:SimpleGraph, k::Int)

Create an intersection representation of `G` using subsets of 
`{1,2,...,k}` or throw an error if not such representation 
exists.
"""
function IntersectionRepresentation(G::SimpleGraph, k::Int)
    if k < 0
        @error "Set size must be nonnegative"
    end

    VV = vlist(G)

    # special case for edgeless graphs 
    if NE(G) == 0
        d = Dict{eltype(G),Set{Int}}()
        for v in G.V
            d[v] = Set{Int}()
        end
        return d
    end

    MOD = Model(get_solver())

    # x[v,i] means integer i is in the set assigned to v

    @variable(MOD, x[VV, 1:k], Bin)

    # y[v,w,i] means integer i is the sets assigned to both v and w

    @variable(MOD, y[VV, VV, 1:k], Bin)

    for v ∈ G.V
        for w ∈ G.V
            if v != w
                for i ∈ 1:k
                    @constraint(MOD, y[v, w, i] <= x[v, i])
                    @constraint(MOD, y[v, w, i] >= x[v, i] + x[w, i] - 1)
                    @constraint(MOD, y[v, w, i] == y[w, v, i])
                end
            end
        end
    end

    for v ∈ G.V
        for w ∈ G.V
            if v != w
                if has(G, v, w)
                    @constraint(MOD, sum(y[v, w, i] for i = 1:k) >= 1)
                else
                    @constraint(MOD, sum(y[v, w, i] for i = 1:k) == 0)
                end
            end
        end
    end

    @objective(MOD, Min, sum(x[v, i] for v ∈ VV for i ∈ 1:k))

    optimize!(MOD)

    status = Int(termination_status(MOD))

    if status != 1
        error("No intersection representation found")
    end

    # @info "Termination status = $status"

    X = value.(x)
    Y = value.(y)


    d = Dict{eltype(G),Set{Int}}()
    for v in VV
        S = Set{Int}()
        for i = 1:k
            if X[v, i] > 0
                push!(S, i)
            end
            d[v] = S
        end
    end

    # sets = values(d)
    # A = union(sets...)
    # i = length(A)

    # @info "Estimated intersection number: $i (upper bound)"

    return d
end


"""
    IntersectionNumber(G)

Compute the intersection number of `G`. 

*Warning*: This can be slow. Use `IntersectionNumber(G,false)` to supress output.
"""
function IntersectionNumber(G::SimpleGraph, verbose::Bool = true)::Int

    if cache_check(G, :IntersectionNumber)
        return cache_recall(G, :IntersectionNumber)
    end

    if verbose
        @info "Test if the graph is triangle free"
    end

    A = adjacency(G)
    t_count = tr(A^3)

    if t_count == 0
        @info "No triangles"
        cache_save(G, :IntersectionNumber, NE(G))
        return NE(G)
    end

    verbose && @info "This graph has triangles"


    if verbose
        @info "Finding an upper bound"
    end

    k = min(NE(G), NV(G))

    go = true
    while go
        if verbose
            @info "Testing if i(G) ≤ $k"
        end
        try
            d = IntersectionRepresentation(G, k)

            sets = values(d)
            A = union(sets...)
            k = length(A)

            go = false
        catch
            verbose && @info "i(G) > $k"
            k *= 2
            k = min(k, NE(G))
        end
    end

    verbose && @info "Confirmed i(G) ≤ $k"

    go = true
    while go
        verbose && @info "Test if i(G) < $k"
        try
            d = IntersectionRepresentation(G, k - 1)
            k -= 1
        catch
            go = false
        end
    end

    cache_save(G, :IntersectionNumber, k)
    return k
end

export IntersectionNumber
