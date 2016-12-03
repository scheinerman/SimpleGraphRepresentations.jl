using SimpleGF2, SimpleGraphs, SimplePosets, Memoize, SimpleGraphAlgorithms

export CircleGraphRepresentation

# AUTHOR: Tara Abrishami

"""
`CircleGraphRepresentation(G)` returns a circle graph representation of the
graph `G` or throws an error if there is none.
"""
function CircleGraphRepresentation(G::SimpleGraph)
  V = vertex_type(G)
  numVert = Dict{Int, V}()
  vertNum = Dict{V, Int}()
  counter = 1
  verts = NV(G)
  z = zeros(GF2, verts*verts + 1)
  C = deepcopy(z)
  vertices = vlist(G)
  for v in vertices
    vertNum[v] = counter
    numVert[counter] = v
    counter = counter + 1
  end
  for e in elist(G) #assigns the beta equations where there are edges
    x = deepcopy(z)
    x[(vertNum[e[1]]-1)*verts + vertNum[e[2]]] = 1
    x[(vertNum[e[2]]-1)*verts + vertNum[e[1]]] = 1
    x[verts*verts + 1] = 1
    C = hcat(C, x)
  end
  n = length(vertices)
  for v in vertices
    for i in 1:n
      for j in 1+i:n
        v1 = vertices[i]
        v2 = vertices[j]
        if (has(G, v, v1) && !has(G, v, v2)) || (has(G, v, v2) && !has(G, v, v1)) || v == v1 || v == v2 || v1 == v2
          continue
        elseif has(G, v, v1) && has(G, v, v2) #assigns the beta equation in the third case
          if !has(G, v1, v2)
            x = deepcopy(z)
            x[(vertNum[v]-1)*verts + vertNum[v1]] = 1
            x[(vertNum[v]-1)*verts + vertNum[v2]] = 1
            x[(vertNum[v1]-1)*verts + vertNum[v2]] = 1
            x[(vertNum[v2]-1)*verts + vertNum[v1]] = 1
            x[verts*verts + 1] = 1
            C = hcat(C, x)
          end
        elseif !has(G, v, v1) && !has(G, v, v2) #assigns the beta equation in the second case
          if has(G, v1, v2)
            x = deepcopy(z)
            x[(vertNum[v]-1)*verts + vertNum[v1]] = 1
            x[(vertNum[v]-1)*verts + vertNum[v2]] = 1
            C = hcat(C, x)
          end
        end
      end
    end
  end
  C = C'
  sol = Array{GF2}()
  try
    sol = solve_augmented(C)
  catch
    error("Not a circle graph")
  end

  ret = Array{Int}(0)
  comps = collect(parts(components(G)))
  for c in comps
    lis = assignOrder(c, G, vertNum, sol, numVert)
    lis = mod(lis-1, verts) + 1
    ret = vcat(ret, flipdim(flipdim(lis, 1), 1))
  end
  retn = Array{V}(length(ret))
  for q in 1:length(ret)
    retn[q] = numVert[ret[q]]
  end
  return retn
end

function assignOrder(c, G, vertNum, sol, numVert)
  order = SimplePoset(Int)
  V = vertex_type(G)
  verts = NV(G)
  siz = length(c)
  arr = Array{V}(siz)
  i = 1
  for x in c
    arr[i] = x
    i = i + 1
  end
  firstVertex = arr[1]
  add!(order, vertNum[firstVertex], vertNum[firstVertex] + verts)
  for i in 2:siz
    add!(order, vertNum[firstVertex], vertNum[arr[i]])
    add!(order, vertNum[firstVertex], vertNum[arr[i]] + verts)
    if has(G, firstVertex, arr[i]) && sol[(vertNum[firstVertex] - 1)*verts + vertNum[arr[i]]] == 1
      add!(order, vertNum[arr[i]], vertNum[firstVertex]+verts)
      add!(order, vertNum[firstVertex]+verts, vertNum[arr[i]] + verts)
    elseif has(G, firstVertex, arr[i]) && sol[(vertNum[firstVertex] - 1)*verts + vertNum[arr[i]]] == 0
      add!(order, vertNum[firstVertex]+verts, vertNum[arr[i]])
      add!(order, vertNum[arr[i]] + verts, vertNum[firstVertex] + verts)
    elseif !has(G, firstVertex, arr[i]) && sol[(vertNum[firstVertex] - 1)*verts + vertNum[arr[i]]] == 1
      add!(order, vertNum[firstVertex]+verts, vertNum[arr[i]])
      add!(order, vertNum[firstVertex] + verts, vertNum[arr[i]] + verts)
    elseif !has(G, firstVertex, arr[i]) && sol[(vertNum[firstVertex] - 1)*verts + vertNum[arr[i]]] == 0
      add!(order, vertNum[arr[i]], vertNum[firstVertex]+verts)
      add!(order, vertNum[arr[i]] + verts, vertNum[firstVertex] + verts)
    end
    for elt in above(order, vertNum[firstVertex]) #there are ambiguity problems with cases 1, 2, 5, and 6
      j = mod(elt, siz)
      if j == 0
        j = siz
      end
      _compareG(order, i, j, vertNum, sol, arr, verts, firstVertex, G)
    end
  end
  m = 1
  while(m != 0)
    orig = length(incomparables(order))
    for x in incomparables(order)
      i = mod(x[1], siz)
      j = mod(x[2], siz)
      if i == 0
        i = siz
      end
      if j == 0
        j = siz
      end
      _compareG(order, i, j, vertNum, sol, arr, verts, firstVertex, G)
      _compareG(order, j, i, vertNum, sol, arr, verts, firstVertex, G)
    end
    fin = length(incomparables(order))
    m = fin - orig
  end
  return _final(order, G, numVert, vertNum)
end

function _compareG(order, i, j, vertNum, sol, arr, verts, firstVertex, G)
  if i == j
    if !has(G, firstVertex, arr[i]) && sol[(vertNum[firstVertex] -1)*verts + vertNum[arr[i]]] == 1 && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 1
      add!(order, vertNum[arr[i]], vertNum[arr[i]] + verts)
    elseif !has(G, firstVertex, arr[i]) && sol[(vertNum[firstVertex] -1)*verts + vertNum[arr[i]]] == 1 && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 0
      add!(order, vertNum[arr[i]] + verts, vertNum[arr[i]])
    elseif !has(G, firstVertex, arr[i]) && sol[(vertNum[firstVertex] -1)*verts + vertNum[arr[i]]] == 0 && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 1
      add!(order, vertNum[arr[i]], vertNum[arr[i]] + verts)
    elseif !has(G, firstVertex, arr[i]) && sol[(vertNum[firstVertex] -1)*verts + vertNum[arr[i]]] == 0 && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 0
      add!(order, vertNum[arr[i]] + verts, vertNum[arr[i]])
    end
  elseif has(G, arr[i], arr[j]) && sol[(vertNum[arr[j]] - 1)*verts + vertNum[arr[i]]] == 1 #if there is an edge and beta is 1
    if (has(order, vertNum[arr[j]] + verts, vertNum[firstVertex] + verts) && has(order, vertNum[arr[j]], vertNum[arr[j]] + verts)) #first case
      add!(order, vertNum[arr[j]], vertNum[arr[i]])
      add!(order, vertNum[arr[i]], vertNum[arr[j]] + verts)
      if has(order, vertNum[arr[i]] + verts, vertNum[firstVertex]+verts) && sol[(vertNum[arr[i]] - 1)*verts + vertNum[firstVertex]] == 1
        add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]] + verts)
      elseif has(order, vertNum[arr[i]] + verts, vertNum[firstVertex]+verts) && sol[(vertNum[arr[i]] - 1)*verts + vertNum[firstVertex]] == 0
        add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]])
      end
    elseif (has(order, vertNum[arr[j]], vertNum[arr[j]] + verts) && has(order, vertNum[firstVertex] + verts, vertNum[arr[j]])) #sixth case
      add!(order, vertNum[arr[j]], vertNum[arr[i]])
      add!(order, vertNum[arr[i]], vertNum[arr[j]] + verts)
      if has(order, vertNum[firstVertex] + verts, vertNum[arr[i]]) && sol[(vertNum[arr[i]] - 1)*verts + vertNum[firstVertex]] == 1
        add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]] + verts)
      elseif has(order, vertNum[firstVertex] + verts, vertNum[arr[i]]) && sol[(vertNum[arr[i]] - 1)*verts + vertNum[firstVertex]] == 0
        add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]])
      end
    elseif (has(order, vertNum[arr[j]], vertNum[firstVertex] + verts) && has(order, vertNum[arr[j]] + verts, vertNum[arr[j]])) #second case
      add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]] + verts)
      add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]])
      if has(order, vertNum[arr[i]], vertNum[firstVertex] + verts) && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 1
        add!(order, vertNum[arr[i]], vertNum[arr[j]] + verts)
      elseif has(order, vertNum[arr[i]], vertNum[firstVertex] + verts) && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 0
        add!(order, vertNum[arr[j]], vertNum[arr[i]])
      end
    elseif (has(order, vertNum[firstVertex] + verts, vertNum[arr[j]] + verts) && has(order, vertNum[arr[j]] + verts, vertNum[arr[j]])) #fifth case
      add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]] + verts)
      add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]])
      if has(order, vertNum[firstVertex] + verts, vertNum[arr[i]] + verts) && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 1
        add!(order, vertNum[arr[j]], vertNum[arr[i]] + verts)
      elseif has(order, vertNum[firstVertex] + verts, vertNum[arr[i]] + verts) && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 0
        add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]] + verts)
      end
    elseif has(order, vertNum[arr[j]], vertNum[arr[j]] + verts) && has(order, vertNum[firstVertex]+verts, vertNum[arr[j]] + verts) && has(G, arr[j], firstVertex) #case 3
      add!(order, vertNum[arr[j]], vertNum[arr[i]])
      add!(order, vertNum[arr[i]], vertNum[arr[j]] + verts)
      if has(order, vertNum[arr[i]] + verts, vertNum[firstVertex]+verts)
        add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]])
      else
        add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]] + verts)
      end
    elseif has(order, vertNum[arr[j]] + verts, vertNum[arr[j]]) && has(order, vertNum[firstVertex] + verts, vertNum[arr[j]]) && has(G, arr[j], firstVertex) #case 4
      add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]] + verts)
      add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]])
      if has(order, vertNum[arr[i]], vertNum[firstVertex] + verts)
        add!(order, vertNum[arr[i]], vertNum[arr[j]] + verts)
      else
        add!(order, vertNum[arr[j]], vertNum[arr[i]])
      end
    end
  elseif has(G, arr[i], arr[j]) && sol[(vertNum[arr[j]] - 1)*verts + vertNum[arr[i]]] == 0 #if there is an edge and beta is 0
    if (has(order, vertNum[arr[j]] + verts, vertNum[firstVertex] + verts) && has(order, vertNum[arr[j]], vertNum[arr[j]] + verts)) #first case
      add!(order, vertNum[arr[j]], vertNum[arr[i]] + verts)
      add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]] + verts)
      if has(order, vertNum[arr[i]], vertNum[firstVertex] + verts) && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 1
        add!(order, vertNum[arr[i]], vertNum[arr[j]])
      elseif has(order, vertNum[arr[i]], vertNum[firstVertex] + verts) && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 0
        add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]])
      end
    elseif has(order, vertNum[arr[j]], vertNum[arr[j]] + verts) && has(order, vertNum[firstVertex] + verts, vertNum[arr[j]]) #sixth case
      add!(order, vertNum[arr[j]], vertNum[arr[i]] + verts)
      add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]] + verts)
      if has(order, vertNum[firstVertex] + verts, vertNum[arr[i]]) && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 1
        add!(order, vertNum[arr[i]], vertNum[arr[j]])
      elseif has(order, vertNum[firstVertex] + verts, vertNum[arr[i]]) && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 0
        add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]])
      end
    elseif (has(order, vertNum[arr[j]], vertNum[firstVertex] + verts) && has(order, vertNum[arr[j]] + verts, vertNum[arr[j]])) #second case
      add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]])
      add!(order, vertNum[arr[i]], vertNum[arr[j]])
      if has(order, vertNum[arr[i]] + verts, vertNum[firstVertex] + verts) && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 1
        add!(order, vertNum[arr[j]], vertNum[arr[i]] + verts)
      elseif has(order, vertNum[arr[i]] + verts, vertNum[firstVertex] + verts) && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 0
        add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]] + verts)
      end
    elseif has(order, vertNum[firstVertex] + verts, vertNum[arr[j]] + verts) && has(order, vertNum[arr[j]] + verts, vertNum[arr[j]]) #fifth case
      add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]])
      add!(order, vertNum[arr[i]], vertNum[arr[j]])
      if has(order, vertNum[firstVertex] + verts, vertNum[arr[i]] + verts) && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 1
        add!(order, vertNum[arr[j]], vertNum[arr[i]] + verts)
      elseif has(order, vertNum[firstVertex] + verts, vertNum[arr[i]] + verts) && sol[(vertNum[arr[i]] -1)*verts + vertNum[firstVertex]] == 0
        add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]] + verts)
      end
    elseif has(order, vertNum[arr[j]], vertNum[arr[j]] + verts) && has(order, vertNum[firstVertex]+verts, vertNum[arr[j]] + verts) && has(G, arr[j], firstVertex) #case 3
      add!(order, vertNum[arr[j]], vertNum[arr[i]] + verts)
      add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]] + verts)
      if has(order, vertNum[arr[i]], vertNum[firstVertex]+verts)
        add!(order, vertNum[arr[i]], vertNum[arr[j]])
      else
        add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]])
      end
    elseif has(order, vertNum[arr[j]] + verts, vertNum[arr[j]]) && has(order, vertNum[firstVertex] + verts, vertNum[arr[j]]) && has(G, arr[j], firstVertex) #case 4
      add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]])
      add!(order, vertNum[arr[i]], vertNum[arr[j]])
      if has(order, vertNum[arr[i]] + verts, vertNum[firstVertex] + verts)
        add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]] + verts)
      else
        add!(order, vertNum[arr[j]], vertNum[arr[i]] + verts)
      end
    end
  elseif !has(G, arr[i], arr[j]) && sol[(vertNum[arr[j]] - 1)*verts + vertNum[arr[i]]] == 1 #if there is not an edge and beta is 1
    if has(order, vertNum[arr[j]] + verts, vertNum[arr[j]]) && has(order, vertNum[firstVertex] + verts, vertNum[arr[j]]) && has(G, arr[j], firstVertex) || has(order, vertNum[firstVertex] + verts, vertNum[arr[j]] + verts) && has(order, vertNum[arr[j]] + verts, vertNum[arr[j]]) || has(order, vertNum[arr[j]], vertNum[firstVertex] + verts) && has(order, vertNum[arr[j]] + verts, vertNum[arr[j]]) #case 4, 5 and 2
      add!(order, vertNum[arr[i]], vertNum[arr[j]])
      add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]])
      add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]])
      add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]] + verts)
    elseif has(order, vertNum[arr[j]], vertNum[arr[j]] + verts) && has(order, vertNum[firstVertex]+verts, vertNum[arr[j]] + verts) && has(G, arr[j], firstVertex) #third case
      if has(order, vertNum[arr[i]], vertNum[firstVertex])
        add!(order, vertNum[arr[i]], vertNum[arr[j]])
      else
        add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]])
      end
      if has(order, vertNum[arr[i]] + verts, vertNum[firstVertex])
        add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]])
      else
        add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]] + verts)
      end
    elseif has(order, vertNum[arr[j]] + verts, vertNum[firstVertex] + verts) && has(order, vertNum[arr[j]], vertNum[arr[j]] + verts) #case 1
      if has(G, arr[i], firstVertex)
        if sol[(vertNum[firstVertex] - 1)*verts + vertNum[arr[i]]] == 1 && sol[(vertNum[arr[i]] - 1)*verts + vertNum[arr[j]]] == 1
          add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]])
        elseif sol[(vertNum[firstVertex] - 1)*verts + vertNum[arr[i]]] == 1 && sol[(vertNum[arr[i]] - 1)*verts + vertNum[arr[j]]] == 0
          add!(order, vertNum[arr[i]], vertNum[arr[j]])
        elseif sol[(vertNum[firstVertex] - 1)*verts + vertNum[arr[i]]] == 0 && sol[(vertNum[arr[i]] - 1)*verts + vertNum[arr[j]]] == 1
          add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]])
        elseif sol[(vertNum[firstVertex] - 1)*verts + vertNum[arr[i]]] == 0 && sol[(vertNum[arr[i]] - 1)*verts + vertNum[arr[j]]] == 0
          add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]] + verts)
        end
      elseif sol[(vertNum[arr[i]] - 1)*verts + vertNum[firstVertex]] == 1 && sol[(vertNum[arr[i]] - 1)*verts + vertNum[arr[j]]] == 0
        add!(order, vertNum[arr[i]], vertNum[arr[j]])
        add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]] + verts)
      elseif sol[(vertNum[arr[i]] - 1)*verts + vertNum[firstVertex]] == 0 && sol[(vertNum[arr[i]] - 1)*verts + vertNum[arr[j]]] == 1
        add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]])
        add!(order, vertNum[arr[j]] + verts, vertNum[arr[i]])
      end
    elseif has(order, vertNum[arr[j]], vertNum[arr[j]] + verts) && has(order, vertNum[firstVertex] + verts, vertNum[arr[j]])
    end
  elseif !has(G, arr[i], arr[j]) && sol[(vertNum[arr[j]] - 1)*verts + vertNum[arr[i]]] == 0 #if there is not an edge and beta is 0
    if (has(order, vertNum[arr[j]] + verts, vertNum[firstVertex] + verts) && has(order, vertNum[arr[j]], vertNum[arr[j]] + verts)) ||  has(order, vertNum[arr[j]], vertNum[arr[j]] + verts) && has(order, vertNum[firstVertex] + verts, vertNum[arr[j]]) #first case and sixth case
      add!(order, vertNum[arr[j]], vertNum[arr[i]])
      add!(order, vertNum[arr[j]], vertNum[arr[i]] + verts)
      add!(order, vertNum[arr[i]], vertNum[arr[j]] + verts)
      add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]] + verts)
    elseif has(order, vertNum[arr[j]], vertNum[arr[j]] + verts) && has(order, vertNum[firstVertex]+verts, vertNum[arr[j]] + verts) && has(G, arr[j], firstVertex) #case 3
      add!(order, vertNum[arr[j]], vertNum[arr[i]])
      add!(order, vertNum[arr[j]], vertNum[arr[i]] + verts)
      add!(order, vertNum[arr[i]], vertNum[arr[j]] + verts)
      add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]] + verts)
    elseif has(order, vertNum[arr[j]] + verts, vertNum[arr[j]]) && has(order, vertNum[firstVertex] + verts, vertNum[arr[j]]) && has(G, arr[j], firstVertex) #case 4
      if has(order, vertNum[arr[i]], vertNum[firstVertex] + verts)
        add!(order, vertNum[arr[i]], vertNum[arr[j]] + verts)
      else
        add!(order, vertNum[arr[j]], vertNum[arr[i]])
      end
      if has(order, vertNum[arr[i]] + verts, vertNum[firstVertex] + verts)
        add!(order, vertNum[arr[i]] + verts, vertNum[arr[j]] + verts)
      else
        add!(order, vertNum[arr[j]], vertNum[arr[i]] + verts)
      end
    end
  end
end

@memoize function _final(P::SimplePoset, G::SimpleGraph, numVert, vertNum)
    T = element_type(P)
    M = maximals(P)
    for x in M
        PP = deepcopy(P)
        delete!(PP,x)
        PP_exts = all_linear_extensions(PP)
        for L in PP_exts
            append!(L,[x])
            L = mod(L-1, NV(G)) + 1
            GG = CircleGraph(L)
            X = relabel(G, vertNum)
            if GG == induce(X, Set(vlist(GG)))
              return L
            end
        end
    end
end
