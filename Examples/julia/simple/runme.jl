include(joinpath(pwd(), "example.jl"))
using .example

counter = Counter(10)
@assert counter.increment() == 11
@assert counter.increment(4) == 15
finalize(counter)
