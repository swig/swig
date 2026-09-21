using Test
include(joinpath(pwd(), "julia_overload_ambig.jl"))
using .julia_overload_ambig

@test isempty(Test.detect_ambiguities(julia_overload_ambig))
a = A()
c = C()
@test f(nothing, a) == 2
@test f(a, nothing) == 3
@test f(nothing, a, 5) == 7
@test f(a, nothing, 5) == 8
@test g(c, c, nothing) == 10
@test g(nothing, nothing, c, 5) == 25
@test h(a, nothing) == 30
@test h(nothing, a) == 40
@test h(c, nothing) == 50
finalize(a)
finalize(c)
