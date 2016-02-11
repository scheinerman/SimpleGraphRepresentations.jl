
export PermutationGraph, RandomPermutationGraph

"""
`PermutationGraph(p,q)` builds a permutation graph based on the
permutations `p` and `q`. There is an edge from `u` to `v` iff
`(p[u]-p[v])*(q[u]-q[v])<0`.
"""
function PermutationGraph(p::Permutation, q::Permutation)
    n = length(p)
    if length(q) != n
        error("Two permutations must be the same length")
    end
    G = IntGraph(n)
    for u=1:n-1
        for v=u+1:n
            if (p[u]-p[v])*(q[u]-q[v]) < 0
                add!(G,u,v)
            end
        end
    end
    return G
end

"""
`PermutationGraph(p)` is equivalent to `PermutationGraph(p,id)` where
`id` is the identity permutation.
"""
function PermutationGraph(p::Permutation)
    n = length(p)
    q = Permutation(n)
    return PermutationGraph(p,q)
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
