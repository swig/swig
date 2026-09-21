using Test
include(joinpath(pwd(), "julia_containers.jl"))
using .julia_containers

@test doubles([1.0, 2.5]) == [1.0, 2.5]
@test doubles([1, 2]) == [1.0, 2.0]
@test integers([typemin(Int64), typemax(Int64)]) == [typemin(Int64), typemax(Int64)]
@test strings(["", "a\0b", "héllo"]) == ["", "a\0b", "héllo"]
@test string_identity("a\0b") == "a\0b"
@test isempty(doubles(Float64[]))
@test isempty(integers(Int64[]))
@test isempty(strings(String[]))
for i in 1:30
    @test pair_strings() == (repeat("a", 10000), repeat("b", 10000))
    GC.gc()
end
