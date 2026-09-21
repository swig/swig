using Test
include(joinpath(pwd(), "julia_basic.jl"))
using .julia_basic

@test add(2, 3) == 5
@test add(2) == 6
@test twice(2.5) == 5.0
@test invert(true) == false
@test greet("world") == "Hello world"
@test_throws julia_basic.SwigError fail()
@test add(3) == 7
counter = Counter(10)
@test julia_basic.increment(counter) == 11
@test counter.increment(4) == 15
@test Counter.answer() == 42
@test julia_basic.Counter_value_get(counter) == 15
julia_basic.Counter_value_set(counter, 21)
@test counter.increment() == 22
finalize(counter)
GC.gc()
