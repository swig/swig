// swift_throws_runme.swift — wrapped functions that throw C++ exceptions are
// surfaced to Swift as throwing functions.

// No exception: the call returns normally.
try might_throw(fail: false)
assert(try safe_divide(a: 10, b: 2) == 5)

// A thrown C++ exception propagates as a Swift error.
var threw = false
do {
    try might_throw(fail: true)
} catch {
    threw = true
}
assert(threw)

threw = false
do {
    _ = try safe_divide(a: 1, b: 0)
} catch {
    threw = true
}
assert(threw)
