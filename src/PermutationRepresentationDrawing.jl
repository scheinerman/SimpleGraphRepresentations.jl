export PermutationRepresentationDrawing

"""
`PermutationRepresentationDrawing(G)` draws a picture of a permtuation
representation of the graph `G` (if one exists). An optional second
argument (of type `Int`) determines the point size of the labels.
"""
function PermutationRepresentationDrawing(G::SimpleGraphs.SimpleGraph,
                                          font_size=8)
  f,g = PermutationRepresentation(G)
  PermutationRepresentationDrawing(f,g,font_size)
end

"""
`PermutationRepresentationDrawing(f,g)` creates a permutation graph
drawing from a pair of dictionaries mapping vertices to integers.
This is used by `PermutationRepresentationDrawing(G)`.
"""
function PermutationRepresentationDrawing(f::Dict{T,Int},g::Dict{T,Int},
                                             font_size=8) where T
  vertices = collect(keys(f))
  n = length(vertices)
  MARKER_SIZE=10

  yy = sqrt(length(f))

  plot()
  for v in vertices
    x = [f[v],g[v]]
    y = [yy,0]
    plot!(x,y,color="black")
  end
  for v in vertices
    plot!([f[v]],[yy],markerstrokecolor="black", markercolor="white", marker=MARKER_SIZE, markerstrokewidth=2)
    plot!([g[v]],[0],markerstrokecolor="black", markercolor="white", marker=MARKER_SIZE, markerstrokewidth=2)
  end

  for v in vertices
    if font_size>0
      annotate!((f[v],yy,string(v),font_size))
      annotate!((g[v],0,string(v),font_size))
    end
  end
  finish()
end
