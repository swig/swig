// swift_static_runme.swift — static (class) methods are exposed as Swift
// type methods.
try Counter.reset()
let a = try Counter.next()
assert(a == 1)
let b = try Counter.next()
assert(b == 2)
try Counter.reset()
let c = try Counter.next()
assert(c == 1)
