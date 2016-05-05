using SimpleGraphs
using SimpleGraphRepresentations
using SimpleGraphDrawings
using PyPlot
using LatexPrint
using ProgressMeter
include("CircleRepresentationDrawing.jl")

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
    #println("intersecting")
    a = list[i+1]
    b = list[i]
    b_locs = find(list .== b)
    j = b_locs[2]
    idx = [ collect(1:i); collect(i+2:j-1); i+1; collect(j:n) ]
  else
    #println("disjoint")
    a = list[i]
    b = list[i+1]
    b_locs = find(list .== b)
    j = b_locs[2]
    idx = [ collect(1:i-1); collect(i+1:j); i; collect(j+1:n)]
  end
  #println(idx)
  return list[idx]
end

function jump_over_left{T}(list::Array{T,1}, i::Int)
  rev_list = reverse(list)
  n = length(list)
  rev_ans  = jump_over_right(rev_list, i)
  return reverse(rev_ans)
end

function rotate{T}(list::Array{T,1})
  n = length(list)
  result = Array{T,1}(n)
  for i=2:n
    result[i] = list[i-1]
  end
  result[1] = list[n]
  return result
end

function build_jump_graph{T}(list::Array{T,1}, early_quit::Bool=true)
  todo = []
  done = Set()
  push!(todo,list)
  G = SimpleGraph{Array{T,1}}()
  add!(G,list)

  while length(todo)>0
    current = pop!(todo)
    if early_quit && maximum(deg(CircleGraph(current))) <= 1
      return G
    end

    if in(current,done)
      continue
    end
    jump_list = find_jumps(current)
    for i in jump_list
      next = jump_over_right(current,i)
      add!(G,current,next)
      push!(todo,next)
    end
    jump_list = find_jumps(reverse(current))
    for i in jump_list
      next = jump_over_left(current,i)
      add!(G,current,next)
      push!(todo,next)
    end
    next = rotate(current)
    add!(G,current,next)
    push!(todo,next)


    push!(done,current)
  end
  return G
end


function path2caravan{T}(list::Array{T,1})
  G = build_jump_graph(list)
  for v in G.V
    H = CircleGraph(v)
    if maximum(deg(H)) <= 1
      p = find_path(G,list,v)
      return p
    end
  end
  error("Cannot reduce to a caravan")
end

function trim_caravan_path{T}(P::Array{Array{T,1},1})
  n = length(P)
  for k=1:n
    G = CircleGraph(P[k])
    if maximum(deg(G))<=1
      return P[1:k]
    end
  end
  return P
end

"""
`average_det(n,reps)`: Generate random circle graphs
and report the average determinant of their cross
matrix.
"""
function average_det(n::Int, reps::Int=1000)
  total = 0.0
  P = Progress(reps,1)
  for k=1:reps
    A = CrossMatrix(RandomCircleRepresentation(n))
    total += round(det(A))
    next!(P)
  end
  return total/reps
end



function caravan_demo_latex{T}(list::Array{T,1})
  P = path2caravan(list)
  P = trim_caravan_path(P)
  np = length(P)
  println("Reduce to caravan in $np steps")
  run(`make very-clean`)
  F = open("caravan.tex","w")

  println(F,"\\documentclass[12pt]{article}")
  println(F,"\\usepackage{graphicx}")
  println(F,"\\usepackage{txfonts}")
  println(F,"\\usepackage[margin=1in]{geometry}")
  println(F,"\\begin{document}")

  for i=1:np
    a = P[i]
    G = CircleGraph(a)
    X = SimpleGraphDrawing(G)
    spectral!(X)
    spring!(X)
    stress!(X)
    figure(1)
    clf()
    set_vertex_size(20)
    draw(X); draw_labels(X)
    savefig("graph-$i.pdf")
    clf()
    RainbowDrawing(a)
    savefig("rainbow-$i.pdf")
    A = CrossMatrix(a)

    println(F,"\\begin{center}")
    println(F,"\\includegraphics[width=0.5\\textwidth]{graph-$i-crop}\\\\")
    println(F,"\\bigbreak\\hrule\\bigbreak")
    println(F,"\\includegraphics[width=0.75\\textwidth]{rainbow-$i-crop}\\\\")
    println(F,"\\[")
    lap(F,A)
    println(F,"\\]")
    println(F,"\\end{center}")
    if i < np
      println(F,"\\newpage")
    end

  end
  println(F,"\\end{document}")
  close(F)
  close()
  run(`make view`)
end
