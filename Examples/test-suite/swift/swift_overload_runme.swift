// swift_overload_runme.swift — overloaded C++ functions become overloaded
// Swift methods, dispatched by argument type and arity.

// Explicit Int32 where an int and double overload share the same argument
// labels, so Swift picks the intended overload rather than reporting ambiguity.
let calc = try Calculator()
let s1 = try calc.add(a: Int32(2), b: Int32(3))
assert(s1 == 5)
let s2 = try calc.add(a: 1.5, b: 2.5)
assert(s2 == 4.0)
let s3 = try calc.add(a: Int32(1), b: Int32(2), c: Int32(3))
assert(s3 == 6)

// Overloaded free functions.
let t1 = try twice(x: Int32(21))
assert(t1 == 42)
let t2 = try twice(x: 1.5)
assert(t2 == 3.0)
