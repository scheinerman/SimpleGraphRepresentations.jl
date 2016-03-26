using PyPlot
"""
`CircleRepresentationDrawing(list)` draws the circle representation
implicit in `list`. Requires `PyPlot`. Not exporting this for that
reason.
"""
function CircleRepresentationDrawing{T}(list::Array{T,1},labels::Bool=true)
  positions = SimpleGraphRepresentations.list2locs(list)
  nn = length(list)
  verts = collect(keys(positions))
  clf()
  rad = 2
  theta = collect(0:360)*pi/180
  x = rad*map(cos,theta)
  y = rad*map(sin,theta)
  plot(x,y,linestyle=":", color="black")

  for v in verts
    p = positions[v]
    a = (p[1]-1)*2*pi/nn
    b = (p[2]-1)*2*pi/nn
    x = rad*[cos(a), cos(b)]
    y = rad*[sin(a), sin(b)]
    plot(x,y,color="black")

    if labels
      mu = 1.1
      for k=1:2
        text(mu*x[k],mu*y[k],string(v))
      end
    end

  end
  axis("equal")
  axis("off")
  nothing
end

"""
`CircleRepresentationDrawing(str::ASCIIString)` uses `str` as the
list of symbols.
"""
function CircleRepresentationDrawing(str::ASCIIString, labels::Bool=true)
  list = [ch for ch in str]
  CircleRepresentationDrawing(list,labels)
end
