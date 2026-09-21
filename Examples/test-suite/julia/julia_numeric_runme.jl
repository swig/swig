using Test
include(joinpath(pwd(), "julia_numeric.jl"))
using .julia_numeric

for value in (typemin(Int64), typemax(Int64), Int64(2)^53 + 1, 0, -1)
    @test roundtrip(value) == value
    @test boxed_roundtrip(value) == value
    @test integer_reference(value) == value
end
@test unsigned_roundtrip(typemax(UInt64)) == typemax(UInt64)
@test signed_byte(-128) == -128
@test unsigned_byte(255) == 255
@test bool_reference(true)
@test_throws InexactError signed_byte(128)
@test_throws InexactError unsigned_byte(-1)
for value in (Inf, -Inf, NaN, 0.5, 2.0^63, -2.0^64, "wrong")
    @test_throws julia_numeric.SwigError boxed_roundtrip(value)
end
@test boxed_roundtrip(12.0) == 12
GC.gc()

@test int_result() === Cint(-123)
@test unsigned_result() === typemax(UInt64)
@test float_result() === 1.25
@test double_result() === -2.5
@test bool_result(false) === false
@test bool_result(true) === true
