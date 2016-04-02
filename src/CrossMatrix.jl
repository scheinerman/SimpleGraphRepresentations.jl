"""
`CrossMatrix(list)` takes a circle representation list
and produces a signed adjacency matrix of the corresponding
circle graph. We have `+1` or `-1` entries depending on
how the segments cross each other. Every segment is oriented
and the sign is determined if based on left-to-right or
right-to-left orientation of the crossing segments.
"""
function CrossMatrix{T}(list::Array{T,1})
  positions = SimpleGraphRepresentations.list2locs(list)
  elts = collect(keys(positions))
  n = length(elts)
  try
    sort!(elts)
  end

  A = zeros(Int,n,n)

  for i=1:n
    v = elts[i]
    a = positions[v]
    for j=1:n
      w = elts[j]
      b = positions[w]
      if a[1]<b[1]<a[2]<b[2]
        A[i,j] = 1
      end
      if b[1]<a[1]<b[2]<a[2]
        A[i,j] = -1
      end
    end
  end
  return A
end

function find_example(n::Int)
  if mod(n,2) == 1
    error("n = $n is not even")
  end
  while true
    lst = RandomCircleRepresentation(n)
    A = CrossMatrix(lst)
    if rank(A) == n
      return lst,A
    end
  end
end
