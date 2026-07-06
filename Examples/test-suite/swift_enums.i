%module swift_enums

// Swift-specific test: C++ enumerations map to Swift enums via swiftenums.swg.

%inline %{

enum Color {
  RED,
  GREEN = 10,
  BLUE
};

enum class Direction {
  NORTH,
  SOUTH,
  EAST,
  WEST
};

// Enums whose enumerators repeat a value cannot be a native Swift enum (raw
// values must be unique), so the backend emits a rawValue struct instead - it
// still exposes rawValue and init?(rawValue:), so the enum typemaps keep working.

// Aliased enumerators: COMP_CCITT_T4 == COMP_CCITTFAX3 and COMP_CCITT_T6 ==
// COMP_CCITTFAX4.  Mirrors real headers such as libtiff's COMPRESSION enum.
enum Compression {
  COMP_NONE = 1,
  COMP_CCITTFAX3 = 3,
  COMP_CCITT_T4 = COMP_CCITTFAX3,
  COMP_CCITTFAX4 = 4,
  COMP_CCITT_T6 = COMP_CCITTFAX4,
  COMP_LZW = 5
};

// Duplicate explicit values followed by an implicit member (which must still
// auto-increment to the correct value in the struct form).
enum Dup {
  DUP_A = 10,
  DUP_B = 10,
  DUP_C
};

Compression identity_compression(Compression c) { return c; }
Dup identity_dup(Dup d) { return d; }

Color next_color(Color c) {
  // Cycle through the (non-contiguous) enumerators, returning a valid Color.
  switch (c) {
  case RED:   return GREEN;
  case GREEN: return BLUE;
  default:    return RED;
  }
}

Direction opposite(Direction d) {
  switch (d) {
  case Direction::NORTH: return Direction::SOUTH;
  case Direction::SOUTH: return Direction::NORTH;
  case Direction::EAST: return Direction::WEST;
  default: return Direction::EAST;
  }
}

%}
