using Test, SimpleGraphs, SimpleGraphRepresentations


G = Cycle(3)
add!(G, 1, 4)
d = IntersectionRepresentation(G,2)
H = IntersectionGraph(d)
@test G == H
