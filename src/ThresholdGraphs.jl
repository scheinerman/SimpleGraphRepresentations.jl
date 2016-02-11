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
`RandomThresholdGraph(n)` creates a random threshold graph with `n`
vertices.
"""
function RandomThresholdGraph(n::Int)
    w = rand(n)
    return ThresholdGraph(w)
end

