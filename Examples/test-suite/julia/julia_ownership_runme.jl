using Test
include(joinpath(pwd(), "julia_ownership.jl"))
using .julia_ownership

@test live_count() == 0
owner = Tracked()
@test live_count() == 1
borrowed = owner.borrow()
reference = owner.reference()
@test borrowed.get() == 7
@test reference.get() == 7
finalize(borrowed)
finalize(reference)
@test live_count() == 1
@test owner.get() == 7
@test null_pointer() === nothing
allocated = make_owned()
@test allocated.get() == 12
value = make_value()
@test value.get() == 18
@test live_count() == 3
finalize(allocated)
finalize(value)
finalize(owner)
@test live_count() == 0
finalize(owner)
@test live_count() == 0
@test_throws julia_ownership.SwigError owner.get()
GC.gc()

function borrow_temporary()
    object = Tracked(29)
    return object.borrow()
end
borrowed = borrow_temporary()
GC.gc()
@test live_count() == 1
@test borrowed.get() == 29
@test unchecked_get(borrowed) == 29
module Impostor
mutable struct Tracked
    ptr::Ptr{Cvoid}
end
end
@test_throws julia_ownership.SwigError unchecked_get(Impostor.Tracked(borrowed.ptr))
finalize(borrowed)
GC.gc()
@test live_count() == 0
