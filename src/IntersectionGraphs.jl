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
    G = UG{S}()
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


function _is_triangle_free(G::UG)::Bool
    A = adjacency(G)
    return tr(A^3) == 0
end

export IntersectionRepresentation
"""
    IntersectionRepresentation(G:UG, k::Int)

Create an intersection representation of `G` using subsets of 
`{1,2,...,k}` or throw an error if not such representation 
exists.

If `k` is omitted, we find a representation with the smallest possible value of `k`.
"""
function IntersectionRepresentation(G::UG{T}, k::Int) where {T}
    if k < 0
        error("Set size must be nonnegative")
    end

    _err_message = "This graph does not have an intersection representation with only $k elements"

    if cache_check(G, :IntersectionNumber)
        i = cache_recall(G, :IntersectionNumber)
        if i > k
            error(_err_message)
        end
        if cache_check(G, :IntersectionRepresentation)
            return cache_recall(G, :IntersectionRepresentation)
        end
    end

    VV = vlist(G)
    d = Dict{T,Set{Int}}()

    # special case for edgeless graphs 
    if NE(G) == 0
        for v in G.V
            d[v] = Set{Int}()
        end
        cache_save(G, :IntersectionRepresentation, d)
        cache_save(G, :IntersectionNumber, 0)
        return d
    end


    # special case for triangle-free graphs

    if _is_triangle_free(G)
        lookup = Dict{Tuple{T,T},Int}()
        EE = elist(G)
        m = length(EE)

        if k < m
            error(_err_message)
        end

        for j = 1:m
            e = EE[j]
            v, w = e
            lookup[(v, w)] = j
            lookup[(w, v)] = j
        end


        for v ∈ VV
            Nv = G[v]
            vals = (lookup[(v, w)] for w ∈ Nv)
            d[v] = Set{Int}(vals)
        end
        cache_save(G, :IntersectionNumber, m)
        cache_save(G, :IntersectionRepresentation, d)
        return d
    end


    # clique number check (generalize)
    ω = length(max_clique(G))
    bound = NE(G) / binomial(ω, 2)
    if k < bound
        @info "Failed clique-size bound"
        error(_err_message)
    end

    # chromatic number of complement 
    bound = chromatic_number(G')
    if k < bound
        @info "Failed chromatic number of complement bound"
        error(_err_message)
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
        error(_err_message)
    end

    X = value.(x)
    Y = value.(y)


    d = Dict{T,Set{Int}}()
    for v in VV
        S = Set{Int}()
        for i = 1:k
            if X[v, i] > 0
                push!(S, i)
            end
            d[v] = S
        end
    end

    return d
end

function IntersectionRepresentation(G::UG)
    k = IntersectionNumber(G)
    return IntersectionRepresentation(G, k)
end


"""
    IntersectionNumber(G)

Compute the intersection number of `G`. 

*Warning*: This can be slow. Use `IntersectionNumber(G,false)` to supress output.
"""
function IntersectionNumber(G::UG, verbose::Bool = true)::Int

    if cache_check(G, :IntersectionNumber)
        return cache_recall(G, :IntersectionNumber)
    end


    if _is_triangle_free(G)
        cache_save(G, :IntersectionNumber, NE(G))
        return NE(G)
    end

    k = min(NE(G), NV(G))

    go = true
    while go
        if verbose
            @info "Testing if i(G) ≤ $k"
        end
        try
            d = IntersectionRepresentation(G, k) |> _relabel_left
            cache_save(G, :IntersectionRepresentation, d)

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

    # verbose && @info "Confirmed i(G) ≤ $k"

    # go = true
    # while go
    #     verbose && @info "Test if i(G) < $k"
    #     try
    #         d = IntersectionRepresentation(G, k - 1) |> _relabel_left
    #         cache_save(G, :IntersectionRepresentation, d)
    #         k -= 1
    #     catch
    #         go = false
    #     end
    # end

    cache_save(G, :IntersectionNumber, k)
    return k
end

export IntersectionNumber


function _relabel_left(d::Dict{T,Set{Int}}) where {T}
    sets = values(d)
    A = sort(collect(union(sets...)))
    k = length(A)

    trans = Dict{Int,Int}()
    for i = 1:k
        trans[A[i]] = i
    end

    new_d = Dict{T,Set{Int}}()
    for v in keys(d)
        S = Set(trans[x] for x in d[v])
        new_d[v] = S
    end
    return new_d
end
export _relabel_left   # debug #
