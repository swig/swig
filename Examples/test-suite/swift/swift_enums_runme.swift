// swift_enums_runme.swift — C/C++ enums map to Swift enums backed by Int32.

// Unscoped enum with an explicit value carries through.
assert(Color.RED.rawValue == 0)
assert(Color.GREEN.rawValue == 10)
assert(Color.BLUE.rawValue == 11)

// Enums round-trip through wrapped functions.
assert(try next_color(c: Color.RED) == Color.GREEN)
assert(try next_color(c: Color.BLUE) == Color.RED)

// Scoped enum (enum class).
assert(try opposite(d: Direction.NORTH) == Direction.SOUTH)
assert(try opposite(d: Direction.EAST) == Direction.WEST)
