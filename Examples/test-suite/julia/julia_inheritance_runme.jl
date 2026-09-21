using Test
include(joinpath(pwd(), "julia_inheritance.jl"))
using .julia_inheritance

value = Derived()
@test value.read_left() == 41
@test value.read_right() == 73
@test read_base(Right()) == 73
@test read_base(value) == 73
finalize(value)
