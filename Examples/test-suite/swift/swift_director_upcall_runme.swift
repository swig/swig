// swift_director_upcall_runme.swift - a director virtual reaches C++ instead of
// running a stub that returns a default value.

// Not overridden: the C++ base implementation runs.
let s = try Shape()
let sSides = try s.sides()
assert(sSides == 42)
let sDescribe = try s.describe()
assert(sDescribe == 42)

// A C++ object handed back in a fresh base-class proxy dispatches virtually to
// the C++ override.
let t = try make_triangle()!
let tSides = try t.sides()
assert(tSides == 3)
let tDescribe = try t.describe()
assert(tDescribe == 3)

// A Swift override runs both from Swift and through C++ virtual dispatch.
class Square: Shape {
    override func sides() throws -> Int32 {
        return 4
    }
}
let sq = try Square()
let sqSides = try sq.sides()
assert(sqSides == 4)
let sqDescribe = try sq.describe()
assert(sqDescribe == 4)

// A proxy wrapping the director object (not the Swift object itself) must
// dispatch virtually, so the Swift override is reached rather than the base.
let alias = try same_shape(s: sq)!
let aliasSides = try alias.sides()
assert(aliasSides == 4)

// Calling a pure virtual that the Swift subclass did not override throws
// instead of returning a default, both directly and through C++.
let sink = try Sink()
var threw = false
do {
    _ = try sink.consume(x: 1)
} catch {
    threw = true
}
assert(threw)
threw = false
do {
    _ = try sink.feed(x: 1)
} catch {
    threw = true
}
assert(threw)

class Doubler: Sink {
    override func consume(x: Int32) throws -> Int32 {
        return x * 2
    }
}
let d = try Doubler()
let fed = try d.feed(x: 21)
assert(fed == 42)
