using PyPlot
"""
`PermutationRepresentationDrawing(G)` draws a picture of a permtuation
representation of the graph `G` (if one exists). An optional second
argument (of type `Bool`) determines if labels are included.
Requires `PyPlot`.
"""
function PermutationRepresentationDrawing(G::SimpleGraphs.SimpleGraph,
                                          labels::Bool=false)
  f,g = PermutationRepresentation(G)
  PermutationRepresentationDrawing(f,g,labels)
end

"""
`PermutationRepresentationDrawing(f,g)` creates a permutation graph
drawing from a pair of dictionaries mapping vertices to integers.
This is used by `PermutationRepresentationDrawing(G)`.
"""
function PermutationRepresentationDrawing{T}(f::Dict{T,Int},g::Dict{T,Int},
                                             labels::Bool=false)
  vertices = collect(keys(f))
  n = length(vertices)
  MARKER_SIZE=15

  clf()
  for v in vertices
    x = [f[v],g[v]]
    y = [1,0]
    plot(x,y,color="black", marker="o", markersize=MARKER_SIZE,
    markerfacecolor="white")
    if labels
      text(f[v],1.1,string(v))
      text(g[v],-0.2,string(v))
    end
  end
  axis("off")
  axis([0.5,n+0.5,-1,2])
  return nothing
end
