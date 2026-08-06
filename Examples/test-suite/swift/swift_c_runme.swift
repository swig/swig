// swift_c_runme.swift — a plain C interface (free functions, a C enum, a POD
// struct and a #define constant) wrapped by the C++-targeting Swift backend
// and executed at runtime.

let sum = try swig_c_add(a: 2, b: 3)
assert(sum == 5)

let scaled = try swig_c_scale(x: 2.0, factor: 1.5)
assert(scaled == 3.0)

assert(SWIFT_C_ANSWER == 42)

let nc1 = try next_color(c: Color.RED)
assert(nc1 == Color.GREEN)
let nc2 = try next_color(c: Color.BLUE)
assert(nc2 == Color.RED)

let p = try make_point(x: 3, y: 4)
let px = try p.GetX()
assert(px == 3)
let py = try p.GetY()
assert(py == 4)
let s = try point_sum(p: p)
assert(s == 7)
