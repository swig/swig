using Test
include(joinpath(pwd(), "julia_typemaps.jl"))
using .julia_typemaps

@test outstanding() == 0
@test consume(19, false) == 19
@test outstanding() == 0
@test_throws julia_typemaps.SwigError consume(19, true)
@test outstanding() == 0
GC.gc()

@test outputs() == (17, 23)

@test julia_typemaps.injected_value == 91
