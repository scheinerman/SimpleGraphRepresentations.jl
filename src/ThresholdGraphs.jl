export ThresholdGraph, RandomThresholdGraph

"""
`ThresholdGraph(w)` creates a threshold graph using weights from the
vector `w`.
"""
function ThresholdGraph{T<:Real}(w::Array{T,1})
    n = length(w)
    G = IntGraph(n)
    for i=1:n-1
        for j=i+1:n
            if w[i]+w[j] >= 1
                add!(G,i,j)
            end
        end
    end
    return G
end

"""
`ThresholdGraph(dw)` creates a threshold graph from a dictionary
mapping vertices to weights.
"""
function ThresholdGraph{S,T<:Real}(dw::Dict{S,T})
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

