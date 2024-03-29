# A tolerance graph is a graph whose vertices are represented by pairs
# (J,t) where J is a closed interval and t is a real number. Vertices
# are adjacent if and only if length(J * JJ) >= min(t,tt).

export ToleranceGraph

"""
`ToleranceGraph(Jlist, tlist)` creates a tolerance graph where `Jlist`
is a list of intervals and `tlist` is a list of tolerances.
"""
function ToleranceGraph(
    Jlist::Vector{ClosedInterval{S}},
    tlist::Vector{T},
) where {S<:Real,T<:Real}
    n = length(Jlist)
    G = IntGraph(n)

    for i = 1:n-1
        J = Jlist[i]
        t = tlist[i]
        for j = i+1:n
            JJ = Jlist[j]
            tt = tlist[j]

            K = J * JJ
            if !isempty(K) && length(K) >= min(t, tt)
                add!(G, i, j)
            end
        end
    end
    return G
end

"""
`ToleranceGraph(f)` creates a tolerance graph where `f` is a `Dict`
mapping vertices to pairs `(J,t)` where `J` is a `ClosedInterval` and
`t` is a `Real` tolerance.
"""
function ToleranceGraph(f::Dict{X,Tuple{ClosedInterval{S},T}}) where {S<:Real,T<:Real,X}
    vtcs = collect(keys(f))
    G = UG{X}()
    for v in vtcs
        add!(G, v)
    end

    n = length(vtcs)
    for i = 1:n-1
        v = vtcs[i]
        J, t = f[v]
        for j = i+1:n
            w = vtcs[j]
            JJ, tt = f[w]

            K = J * JJ
            if !isempty(K) && length(K) >= min(t, tt)
                add!(G, v, w)
            end
        end
    end
    return G
end
