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

// Enums with duplicate / aliased values: emitted as a rawValue struct, still
// usable via rawValue, equality, and through wrapped functions.
assert(Compression.COMP_NONE.rawValue == 1)
assert(Compression.COMP_CCITTFAX3.rawValue == 3)
assert(Compression.COMP_CCITT_T4.rawValue == 3)   // alias of COMP_CCITTFAX3
assert(Compression.COMP_CCITTFAX4.rawValue == 4)
assert(Compression.COMP_CCITT_T6.rawValue == 4)   // alias of COMP_CCITTFAX4
assert(Compression.COMP_LZW.rawValue == 5)
assert(Compression.COMP_CCITT_T4 == Compression.COMP_CCITTFAX3)

let comp = try identity_compression(c: Compression.COMP_LZW)
assert(comp == Compression.COMP_LZW)
assert(comp.rawValue == 5)

// Duplicate explicit values with a trailing implicit member.
assert(Dup.DUP_A.rawValue == 10)
assert(Dup.DUP_B.rawValue == 10)
assert(Dup.DUP_C.rawValue == 11)   // implicit: auto-incremented from 10
assert(Dup.DUP_A == Dup.DUP_B)

let dup = try identity_dup(d: Dup.DUP_C)
assert(dup == Dup.DUP_C)

// A nested enum named "Type" (Shape::Type) is %rename'd to Kind (to avoid the
// Swift .Type metatype clash) and stays nested, so it is referenced as
// Shape.Kind both from a method and from a free function.
let shape = try Shape(t: Shape.Kind.SQUARE)
let shapeKind = try shape.getType()
assert(shapeKind == Shape.Kind.SQUARE)
let circleOrdinal = try typeOrdinal(t: Shape.Kind.CIRCLE)
assert(circleOrdinal == 0)
let squareOrdinal = try typeOrdinal(t: Shape.Kind.SQUARE)
assert(squareOrdinal == 1)
