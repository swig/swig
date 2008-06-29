#include <stdio.h>

#include "example_proxy.h"

int main(int argc, char **argv) {
  Circle* pc = new_Circle(10.0);
  Square* ps = new_Square(10.0);

  printf("Circle perim.=%f, area=%f\n", Circle_perimeter(pc), Circle_area(pc));
  printf("Square perim.=%f, area=%f\n", Square_perimeter(ps), Square_area(ps));

  printf("Circle pos.=(%f, %f)\n", Shape_get_x(pc), Shape_get_y(pc));
  Shape_move(pc, 5.0, -5.0);
  printf("After move pos.=(%f, %f)\n", Shape_get_x(pc), Shape_get_y(pc));
  
  delete_Square(ps);
  delete_Circle(pc);
}

