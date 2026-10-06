// runme.swift — drives the SWIG "class" example from Swift.
//
// Demonstrates wrapping C++ classes: construction, single inheritance
// (Circle/Square derive from Shape) and virtual method dispatch (area/perimeter
// resolve to the derived implementation through the C++ vtable).

func approx(_ a: Double, _ b: Double) -> Bool { return abs(a - b) < 1e-6 }

// Create a Circle and a Square.
let c = try Circle(r: 5.0)
let s = try Square(w: 4.0)

// Virtual methods dispatch to the concrete subclass implementation.
let ca = try c.area()
let cp = try c.perimeter()
print("Circle:  area = \(ca), perimeter = \(cp)")
assert(approx(ca, 78.53981633974483))
assert(approx(cp, 31.41592653589793))

let sa = try s.area()
let sp = try s.perimeter()
print("Square:  area = \(sa), perimeter = \(sp)")
assert(approx(sa, 16.0))
assert(approx(sp, 16.0))

// A Shape reference calls the derived area() through the C++ vtable.
let shape: Shape = c
let da = try shape.area()
assert(approx(da, ca))
print("Polymorphic area via Shape reference = \(da)")
