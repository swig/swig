// swift_overload_runme.swift — overloaded C++ functions become overloaded
// Swift methods, dispatched by argument type and arity.

let calc = try Calculator()
assert(try calc.add(a: 2, b: 3) == 5)
assert(try calc.add(a: 1.5, b: 2.5) == 4.0)
assert(try calc.add(a: 1, b: 2, c: 3) == 6)

// Overloaded free functions.
assert(try twice(x: 21) == 42)
assert(try twice(x: 1.5) == 3.0)
