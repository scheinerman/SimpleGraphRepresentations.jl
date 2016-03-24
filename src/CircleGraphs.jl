export CircleGraph, RandomCircleGraph, RandomCircleRepresentation

"""
`list2locs(list)` takes a list of values as input. Every item on the list
should appear exactly twice. This function returns a dictionary mapping
items on the list to a pair of positive integers giving the two locations
of that element in the list. It's a helper function used by
`CircleGraph`.
"""
function list2locs{T}(list::Array{T,1})
  # build a map giving the locations of each symbol on the list
  err_msg = "Invalid input list"
  # check that the list length is even
  n = length(list)
  if n%2 == 1
    error(err_msg)
  end

  positions = Dict{T, Vector{Int}}()

  for i=1:n
    elt::T = list[i]
    if haskey(positions,elt)  # already have 1st position
      if positions[elt][2] > 0  # and already have 2nd; that's bad
        error(err_msg)
      else
        positions[elt][2] = i
      end
    else # never seen this element before
      positions[elt] = [i,0]
    end
  end
  return positions
end

"""
`CircleGraph(list)` takes a list of elements and creates a circle
graph from them. Every element on the list should appear exactly
twice on the list, or else an error is thrown.
"""
function CircleGraph{T}(list::Array{T,1})
  positions = list2locs(list)

  elts = collect(keys(positions))
  n = length(elts)

  G = SimpleGraph{T}()
  for v in elts
    add!(G,v)
  end

  for i=1:n-1
    v = elts[i]
    a = positions[v]
    for j=i+1:n
      w = elts[j]
      b = positions[w]
      if a[1]<b[1]<a[2]<b[2] || b[1]<a[1]<b[2]<a[2]
        add!(G,v,w)
      end
    end
  end

  return G
end

"""
`RandomCircleRepresentation(n)` returns a `2n` long list
consisting of the numbers `1:n` each exacty twice in some
random order.
"""
function RandomCircleRepresentation(n::Int)
  list = [collect(1:n);collect(1:n)]
  p = randperm(2n)
  return list[p]
end

"""
`RandomCircleGraph(n)` creates a random circle graph with `n`
vertices.
"""
function RandomCircleGraph(n::Int)
  return CircleGraph(RandomCircleRepresentation(n))
end
