export ThresholdGraph, RandomThresholdGraph, CreationSequence, ThresholdRepresentation



"""
`ThresholdGraph(w)` creates a threshold graph using weights from the
vector `w`.

`ThresholdGraph(dw)` creates a threshold graph from a dictionary
mapping vertices to weights.
"""
function ThresholdGraph(w::Array{T,1}) where T<:Real
  n = length(w)
  f = Dict{Int,T}()
  for k=1:n
    f[k] = w[k]
  end
  return ThresholdGraph(f)
end

function ThresholdGraph(dw::Dict{S,T}) where {S,T<:Real}
    G = SimpleGraph{S}()
    vtcs = collect(keys(dw))
    n = length(vtcs)

    for v in vtcs
        add!(G,v)
    end

    for i=1:n-1
        u = vtcs[i]
        wt_u = dw[u]
        for j=i+1:n
            v = vtcs[j]
            wt_v = dw[v]
            if wt_u + wt_v >= 1
                add!(G,u,v)
            end
        end
    end
    cache_save(G,:ThresholdRepresentation,dw)
    cache_save(G,:name,"Threshold graph")
    return G
end

"""
`RandomThresholdGraph(n)` creates a random threshold graph with `n`
vertices.
"""
function RandomThresholdGraph(n::Int)
    w = rand(n)
    return ThresholdGraph(w)
end


# The following code contributed by Tara Abrishami

"""
`CreationSequence(G)` creates a creation sequence for a threshold
graph `G`. This returns a pair `(seq, vtx_list)` where `seq` is the
creation sequence and `vtx_list` specifies the order in which the
vertices are added when creating `G`. If `G` is not a threshold
graph, then an error is raised.
"""
function CreationSequence(G1::SimpleGraph)
    A = Int[]
    T = eltype(G1)
    V = T[]
    G = deepcopy(G1)
    while length(vlist(G)) !=0
        r = false;
        for v in vlist(G)
            if deg(G, v) == 0
                delete!(G, v)
                r = true
                unshift!(A,0)
                unshift!(V,v)
                break
            end
      if deg(G, v) == NV(G) -1
          delete!(G, v)
          r = true
          unshift!(A, 1)
          unshift!(V,v)
          break
      end
    end
        if !r
            error("This graph is not a threshold graph")
        end
    end
    return A, V
end

"""
`ThresholdRepresentation(G)` returns a threshold representation of
`G`. This returns a dictionary mapping vertices of `G` to `Rational`
weights. An error is raised if `G` is not a threshold graph.
"""
function ThresholdRepresentation(G::SimpleGraph)
    if cache_check(G,:ThresholdRepresentation)
      return cache_recall(G,:ThresholdRepresentation)
    end
    A,V = CreationSequence(G)

    prev::Int = 0
    prevVal::Rational = 1//3
    T = eltype(G)
    D = Dict{T, Rational}()
    D[V[1]] = prevVal
    small::Rational = prevVal
    large::Rational = prevVal
    for i in 2:length(A)
        if A[i] == prev
            D[V[i]] = prevVal
        elseif A[i] == 0
            D[V[i]] = (1-large)/2
            prevVal = (1-large)/2
            if (1-large)/2 < small
                small = (1-large)/2
            end
            if (1-large)/2 > large
                large = (1-large)/2
            end
        elseif A[i] == 1
            D[V[i]] = 1 - small
            prevVal = 1 - small
            if 1 - small > large
                large = 1 - small
            end
            if 1 - small < large
                small = 1 - large
            end
        end
        prev = i
    end
    cache_save(G,:ThresholdRepresentation,D)
    return D
end
