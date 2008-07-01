#include <stdio.h>

#include "example_proxy.h"

int main(int argc, char **argv) {
  printf("Creating some objects:\n");
  Circle* c = new_Circle(10);
  printf("    Created circle\n");
  Square* s = new_Square(10);
  printf("    Created square\n");

  printf("\nA total of %d shapes were created\n", 0);

  Circle_set_x(c, 20);
  Circle_set_y(c, 30);

  Shape* shape = (Shape*) s;
  Shape_set_x(shape, -10);
  Shape_set_y(shape, 5);

  printf("\nHere is their current positions:\n");
  printf("    Circle = (%f %f)\n", Circle_get_x(c), Circle_get_y(c));
  printf("    Square = (%f %f)\n", Square_get_x(s), Square_get_y(s));

  printf("\nHere are some properties of the shapes:\n");
  Shape* shapes[] = {(Shape*) c, (Shape*) s};
  int i;
  for (i = 0; i < 2; i++) {
    printf("    %s\n", i ? "Square" : "Circle");
    printf("    area      = %f\n", Shape_area(shapes[i]));
    printf("    perimeter = %f\n", Shape_perimeter(shapes[i]));
  }

  printf("\nGuess I'll clean up now\n");

  delete_Square(s);
  delete_Circle(c);

  printf("%d shapes remain\n", 0);
  printf("Goodbye\n");
}

