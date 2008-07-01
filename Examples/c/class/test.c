#include <stdio.h>

#include "example_proxy.h"

int main(int argc, char **argv) {
  printf("Creating some objects:\n");
  Circle* c = new_Circle(10);
  printf("    Created circle\n");
  Square* s = new_Square(10);
  printf("    Created square\n");

  printf("\nA total of %d shapes were created\n", 0);

  printf("\nHere are some properties of the shapes:\n");
  Shape shapes[] = {c, s};
  int i;
  /*
   * TODO: support for virtual functions
  for (i = 0; i < 2; i++) {
    printf("    area      = %f\n", Shape_area(shapes[i]));
    printf("    perimeter = %f\n", Shape_perimeter(shapes[i]));
  }
  */

  // call methods directly by now
  printf("Circle perim.=%f, area=%f\n", Circle_perimeter(c), Circle_area(c));
  printf("Square perim.=%f, area=%f\n", Square_perimeter(s), Square_area(s));

  printf("\nGuess I'll clean up now\n");

  delete_Square(s);
  delete_Circle(c);

  printf("%d shapes remain\n", 0);
  printf("Goodbye\n");
}

