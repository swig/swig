// swift_enums_runme.swift — C/C++ enums map to Swift enums backed by Int32.

// Unscoped enum with an explicit value carries through.
assert(Color.RED.rawValue == 0)
assert(Color.GREEN.rawValue == 10)
assert(Color.BLUE.rawValue == 11)

// Enums round-trip through wrapped functions.
let nc1 = try next_color(c: Color.RED)
assert(nc1 == Color.GREEN)
let nc2 = try next_color(c: Color.BLUE)
assert(nc2 == Color.RED)

// Scoped enum (enum class).
let op1 = try opposite(d: Direction.NORTH)
assert(op1 == Direction.SOUTH)
let op2 = try opposite(d: Direction.EAST)
assert(op2 == Direction.WEST)
