#include <iostream>

#include "example_wrap.h"

int main(int argc, char **argv) {
  { // Block containing the Circle and Square objects.
  std::cout << "Creating some objects from C++:\n";
  example::Circle c(10);
  std::cout << "    Created circle\n";
  example::Square s(10);
  std::cout << "    Created square\n";

  std::cout << "\nA total of " << example::Shape::nshapes() << " shapes were created\n";

  c.x(20);
  c.y(30);

  example::Shape& shape = s;
  shape.x(-10);
  shape.y(5);

  std::cout << "\nHere is their current positions:\n";
  std::cout << "    Circle = (" << c.x() << " " << c.y() << ")\n";
  std::cout << "    Square = (" << s.x() << " " << s.y() << ")\n";

  std::cout << "\nHere are some properties of the shapes:\n";
  example::Shape* shapes[] = {&c, &s};
  for (int i = 0; i < 2; i++) {
    std::cout << "    " << (i ? "Square" : "Circle") << "\n";
    std::cout << "    area      = " << shapes[i]->area() << "\n";
    std::cout << "    perimeter = " << shapes[i]->perimeter() << "\n";
  }

  std::cout << "\nGuess I'll clean up now\n";
  }

  std::cout << example::Shape::nshapes() << " shapes remain\n";
  std::cout << "Goodbye from C++\n";

  return 0;
}
