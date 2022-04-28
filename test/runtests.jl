using Test, SimpleGraphs, SimpleGraphRepresentations


G = Cycle(3)
add!(G, 1, 4)
d = IntersectionRepresentation(G)
H = IntersectionGraph(d)
@test G == H


G = Cube(3)
d = IntersectionRepresentation(G)
H = IntersectionGraph(d)
@test G == H