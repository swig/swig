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
  return c == BLUE ? RED : (Color)(c + 1);
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
