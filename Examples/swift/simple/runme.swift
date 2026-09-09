// runme.swift — drives the SWIG "simple" example from Swift.
//
// The module wraps a C function (gcd) and a C global variable (Foo).  Free
// functions become Swift free functions; a global variable becomes Foo_get()
// and Foo_set() accessors.

// Call a wrapped C function.
let g = try gcd(x: Int32(42), y: Int32(56))
print("gcd(42, 56) = \(g)")
assert(g == 14)

// Read a wrapped global variable.
let foo = try Foo_get()
print("Foo = \(foo)")
assert(foo == 3.0)

// Write it and read it back.
try Foo_set(Foo: 42.0)
let foo2 = try Foo_get()
print("Foo is now \(foo2)")
assert(foo2 == 42.0)
