// swift_string_runme.swift — std::string maps to Swift String, round-tripped
// through wrapped functions.
let g = try greet(name: "World")
assert(g == "Hello, World")
let n = try length(s: "abcde")
assert(n == 5)
let e = try echo(s: "roundtrip")
assert(e == "roundtrip")
