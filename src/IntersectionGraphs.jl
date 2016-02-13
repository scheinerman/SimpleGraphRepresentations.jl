export IntersectionGraph

AnySet = Union{Set,IntSet}

function IntersectionGraph{T<:AnySet}(slist::Vector{T})
    n = length(slist)
    G = IntGraph(n)

    for u=1:n-1
        A = slist[u]
        for v=u+1:n
            B = slist[v]
            if length(intersect(A,B))>0
                add!(G,u,v)
            end
        end
    end
    return G
end


function IntersectionGraph{S,T<:AnySet}(f::Dict{S,T})
    G = SimpleGraph{S}()
    for v in keys(f)
        add!(G,v)
    end

    vtcs = vlist(G)
    n = length(vtcs)

    for i=1:n-1
        u = vtcs[i]
        A = f[u]
        for j=i+1:n
            v = vtcs[j]
            B = f[v]

            if length(intersect(A,B))>0
                add!(G,u,v)
            end
        end
    end

    return G
end
    
