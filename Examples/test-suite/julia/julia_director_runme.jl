using Test
include(joinpath(pwd(), "julia_director.jl"))
using .julia_director

struct Override end
julia_director.Callback_value(::Override, n) = n * 3
callback = Callback(Override())
GC.gc()
@test callback.call(7) == 21
@test callback.call_real(8.0) == 4.0
@test length(julia_director._swig_director_roots) == 1
finalize(callback)
@test isempty(julia_director._swig_director_roots)

struct Throwing end
julia_director.Callback_value(::Throwing, n) = error("callback failure")
callback = Callback(Throwing())
@test_throws julia_director.SwigError callback.call(1)
GC.gc()
@test callback.call_real(8.0) == 4.0
finalize(callback)
@test isempty(julia_director._swig_director_roots)

struct WrongType end
julia_director.Callback_value(::WrongType, n) = "invalid"
callback = Callback(WrongType())
for i in 1:10
    @test_throws julia_director.SwigError callback.call(1)
    @test caught_frame_restored(callback)
    GC.gc()
end
finalize(callback)
@test isempty(julia_director._swig_director_roots)

mutable struct SharedOverride
    n::Int
end
julia_director.Callback_value(self::SharedOverride, n) = self.n
function make_shared_callbacks()
    self = SharedOverride(19)
    (Callback(self), Callback(self), WeakRef(self))
end
first, second, weak = make_shared_callbacks()
@test length(julia_director._swig_director_roots) == 2
finalize(first)
GC.gc(true)
@test length(julia_director._swig_director_roots) == 1
@test weak.value !== nothing
@test second.call(1) == 19
finalize(second)
GC.gc(true)
@test isempty(julia_director._swig_director_roots)
@test weak.value === nothing

struct IntegerResult
    value::Int64
end
julia_director.Callback_value(self::IntegerResult, n) = self.value
julia_director.Callback_unsigned_value(self::IntegerResult, n) = self.value
for value in (Int64(typemin(Cint)), Int64(typemax(Cint)))
    local callback = Callback(IntegerResult(value))
    @test callback.call(0) == value
    finalize(callback)
end
for value in (Int64(typemin(Cint)) - 1, Int64(typemax(Cint)) + 1, typemin(Int64), typemax(Int64))
    local callback = Callback(IntegerResult(value))
    @test_throws julia_director.SwigError callback.call(0)
    @test caught_frame_restored(callback)
    finalize(callback)
end
for value in (Int64(-1), Int64(typemax(Cuint)) + 1)
    local callback = Callback(IntegerResult(value))
    @test_throws julia_director.SwigError callback.call_unsigned(0)
    finalize(callback)
end
callback = Callback(IntegerResult(Int64(typemax(Cuint))))
@test callback.call_unsigned(0) == typemax(Cuint)
finalize(callback)

struct Echo end
julia_director.Callback_echo(::Echo, value) = value
callback = Callback(Echo())
@test callback.call_echo("a\0b") == "a\0b"
finalize(callback)
@test isempty(julia_director._swig_director_roots)

struct SizeArgument end
julia_director.Callback_size_value(::SizeArgument, n) = n == 17 ? 7 : 0
callback = Callback(SizeArgument())
@test callback.call_size(17) == 7
if sizeof(Csize_t) == 8
    @test_throws julia_director.SwigError callback.call_size(typemax(Csize_t))
end
finalize(callback)
@test isempty(julia_director._swig_director_roots)
