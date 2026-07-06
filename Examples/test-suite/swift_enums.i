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
