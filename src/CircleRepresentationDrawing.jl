

export CircleRepresentationDrawing, RainbowDrawing


"""
`CircleRepresentationDrawing(list, fontsize=8)` draws the circle representation
implicit in `list`. Requires `PyPlot`. Not exporting this for that
reason.
"""
function CircleRepresentationDrawing(list::Array{T,1},font_size=8) where T
  font_size=8
  positions = SimpleGraphRepresentations.list2locs(list)
  nn = length(list)
  verts = collect(keys(positions))
  rad = 2
  theta = collect(0:360)*pi/180
  x = rad*map(cos,theta)
  y = rad*map(sin,theta)
  plot(x,y,linestyle=:dot, color="black")

  for v in verts
    p = positions[v]
    a = (p[1]-1)*2*pi/nn
    b = (p[2]-1)*2*pi/nn
    x = rad*[cos(a), cos(b)]
    y = rad*[sin(a), sin(b)]
    plot!(x,y,color="black")

    if font_size > 0
      mu = 1.1
      for k=1:2
        # text(mu*x[k],mu*y[k],string(v))
        annotate!(mu*x[k],mu*y[k],string(v),font_size)
      end
    end

  end
  finish()
end

"""
`CircleRepresentationDrawing(str::String)` uses `str` as the
list of symbols.
"""
function CircleRepresentationDrawing(str::String, labels::Bool=true)
  list = [ch for ch in str]
  CircleRepresentationDrawing(list,labels)
end

function semicircle(x1::Number, x2::Number, diam=2)
  ctr = (x1+x2)/2
  rad = abs(x1-x2)/2

  angles = collect(0:180)*(pi/180)
  x = rad*[ cos(t) for t in angles ] .+ ctr
  y = rad*[ sin(t) for t in angles ]
  plot!(x,y,color="black", linestyle=:dot)
  plot!([x[1]],[y[1]],marker=diam, markercolor="black")
  plot!([x[end]],[y[end]],marker=diam, markercolor="black")
end

"""
`RainbowDrawing(lst,font_size=8)` creates a rainbow representation
of a circle graph from a list of the positions.
"""
function RainbowDrawing(list::Array{T,1}, font_size::Int = 8) where T
  positions = SimpleGraphRepresentations.list2locs(list)
  nn = length(list)
  verts = collect(keys(positions))

  x = [0,nn+1]
  y = [0,0]
  plot(x,y,color="black")

  gap = -0.5
  for v in verts
    p = positions[v]
    semicircle(p[1],p[2])
    if font_size > 0
        annotate!(p[1],gap,string(v),font_size)
        annotate!(p[2],gap,string(v),font_size)
    end
  end

  finish()
end
