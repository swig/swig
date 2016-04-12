#include <stdio.h>

#include "example_wrap.h"

int main(int argc, char **argv) {
  printf("Creating some objects:\n");
  Circle* c = new_Circle(10);
  printf("    Created circle\n");
  Square* s = new_Square(10);
  printf("    Created square\n");

  printf("\nA total of %d shapes were created\n", Shape_nshapes_get());

  Circle_x_set(c, 20);
  Circle_y_set(c, 30);

  Shape* shape = (Shape*) s;
  Shape_x_set(shape, -10);
  Shape_y_set(shape, 5);

  printf("\nHere is their current positions:\n");
  printf("    Circle = (%f %f)\n", Circle_x_get(c), Circle_y_get(c));
  printf("    Square = (%f %f)\n", Square_x_get(s), Square_y_get(s));

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

  printf("%d shapes remain\n", Shape_nshapes_get());
  printf("Goodbye\n");

  SWIG_exit(0);
}

