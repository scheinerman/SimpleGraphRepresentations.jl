module SimpleGraphRepresentations

using SimpleGraphs
using Permutations
using ClosedIntervals
using SimplePartitions
using Random
using SimpleDrawing, Plots, LinearAlgebra


using JuMP, ChooseOptimizer

import SimpleGraphs.cache_save

# include("drawing_master.jl")
include("IntervalGraphs.jl")
include("PermutationGraphs.jl")
include("PermutationRepresentationDrawing.jl")
include("ThresholdGraphs.jl")
include("IntersectionGraphs.jl")
include("GeometricGraphs.jl")
include("ToleranceGraphs.jl")
include("CircleGraphs.jl")
include("CircleRepresentationDrawing.jl")
include("CircleGraphRepresentation.jl")
include("Cographs.jl")
end # end of module
