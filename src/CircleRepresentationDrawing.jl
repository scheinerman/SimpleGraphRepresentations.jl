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

function semicircle(x1::Number, x2::Number)
  ctr = (x1+x2)/2
  rad = abs(x1-x2)/2

  angles = collect(0:180)*(pi/180)
  x = rad*[ cos(t) for t in angles ] + ctr
  y = rad*[ sin(t) for t in angles ]
  plot(x,y,"-",color="black")
  plot(x[1],y[1],"ok")
  plot(x[end],y[end],"ok")
  axis("equal")
  nothing
end

"""
`RainbowDrawing(lst)` creates a rainbow representation
of a circle graph from a list of the positions.
"""
function RainbowDrawing{T}(list::Array{T,1})
  positions = SimpleGraphRepresentations.list2locs(list)
  nn = length(list)
  verts = collect(keys(positions))
  clf()
  gap = -0.25
  for v in verts
    p = positions[v]
    semicircle(p[1],p[2])
    text(p[1],gap,string(v))
    text(p[2],gap,string(v))
  end

  x = [0,nn+1]
  y = [0,0]
  plot(x,y,"-",color="black")

  axis("off")
  axis("equal")
  nothing
end
