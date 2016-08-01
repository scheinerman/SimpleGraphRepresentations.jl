export RandomCograph, is_cograph

"""
`RandomCograph(vtcs)` creates a random cograph with vertices
in `vtcs`.

`RandomCograph(n)` creates a random cograph with vertex set `1:n`.
"""
function RandomCograph{T}(vtcs::Vector{T})
  G = SimpleGraph{T}()

  # basis cases
  if length(vtcs) == 0
    return G
  end
  if length(vtcs) == 1
    add!(G,vtcs[1])
    return G
  end

  # split the vertex set
  alist = Vector{T}()
  blist = Vector{T}()
  while length(alist)==0 || length(blist)==0
    alist = Vector{T}()
    blist = Vector{T}()
    for v in vtcs
      if rand() < 0.5
        push!(alist,v)
      else
        push!(blist,v)
      end
    end
  end

  # recurse
  G = RandomCograph(alist)
  H = RandomCograph(blist)

  # copy H into G
  for v in blist
    add!(G,v)
  end
  for e in elist(H)
    add!(G,e[1],e[2])
  end

  # final coin flip
  if rand() < 0.5
    for a in alist
      for b in blist
        add!(G,a,b)
      end
    end
  end

  return G
end

RandomCograph(n::Int)    = RandomCograph(collect(1:n))
RandomCograph(A::IntSet) = RandomCograph(collect(A))
RandomCograph(A::Set)    = RandomCograph(collect(A))



"""
`is_cograph(G)` returns `true` is `G` is a cograph, i.e., a
complement reducible graph.
"""
function is_cograph{T}(G::SimpleGraph{T})
  if NV(G) <= 3    # all graphs with 3 or fewer vertices are cographs
    return true
  end
  if is_connected(G)
    GG = G'
    if is_connected(GG)
      return false
    end
    return is_cograph(GG)
  end

  clist = components(G)
  for A in clist
    H = induce(G,A)
    if !is_cograph(H)
      return false
    end
  end
  return true
end
