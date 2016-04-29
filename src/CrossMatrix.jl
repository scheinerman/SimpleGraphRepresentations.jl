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

function find_firsts_seconds{T}(list::Array{T,1})
  F = Set{T}()  # firsts
  n = length(list)
  res = zeros(Int,n)
  for i=1:n
    x = list[i]
    if in(x,F)
      res[i]=2
    else
      push!(F,x)
      res[i]=1
    end
  end
  return res
end


function find_jumps{T}(list::Array{T,1})
  n = length(list)
  fs = find_firsts_seconds(list)

  jumps = Int[]

  for i=1:n-1
    if fs[i] != fs[i+1] && list[i] != list[i+1]
      push!(jumps,i)
    end
  end
  return jumps
end

# There's a spot at i,i+1 for a jump. Move the i to the right.
function jump_over_right{T}(list::Array{T,1}, i::Int)
  n = length(list)
  fs = find_firsts_seconds(list)
  if fs[i] == fs[i+1]
    error("Not a valid jump location")
  end

  if fs[i] == 1
    println("intersecting")
    a = list[i+1]
    b = list[i]
    b_locs = find(list .== b)
    j = b_locs[2]
    idx = [ collect(1:i); collect(i+2:j-1); i+1; collect(j:n) ]
  else
    println("disjoint")
    a = list[i]
    b = list[i+1]
    b_locs = find(list .== b)
    j = b_locs[2]
    idx = [ collect(1:i-1); collect(i+1:j); i; collect(j+1:n)]
  end
  println(idx)
  return list[idx]
end


function build_jump_graph{T}(list::Array{T,1})
  todo = []
  done = Set()
  push!(todo,list)
  G = SimpleGraph()
  add!(G,list)

  while length(todo)>0
    current = pop!(todo)
    if in(current,done)
      continue
    end
    jump_list = find_jumps(current)
    for i in jump_list
      next = jump_over_right(current,i)
      add!(G,current,next)
      push!(todo,next)
    end
    push!(done,current)
  end
  return G
end
