module SimpleGraphRepresentations

using SimpleGraphs
using Permutations
using ClosedIntervals
using SimplePartitions
using Random

import SimpleGraphs.cache_save

include("IntervalGraphs.jl")
include("PermutationGraphs.jl")
include("ThresholdGraphs.jl")
include("IntersectionGraphs.jl")
include("GeometricGraphs.jl")
include("ToleranceGraphs.jl")
include("CircleGraphs.jl")
include("CircleRepresentationDrawing.jl")
include("CircleGraphRepresentation.jl")
include("Cographs.jl")
end # end of module
