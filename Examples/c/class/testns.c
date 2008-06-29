#include <stdio.h>

#include "example_proxy.h"

int main(int argc, char **argv) {
  geom_Circle* pc = new_geom_Circle(10.0);
  geom_Square* ps = new_geom_Square(10.0);

  printf("Circle perim.=%f, area=%f\n", geom_Circle_perimeter(pc), geom_Circle_area(pc));
  printf("Square perim.=%f, area=%f\n", geom_Square_perimeter(ps), geom_Square_area(ps));

  printf("Circle pos.=(%f, %f)\n", geom_Shape_get_x(pc), geom_Shape_get_y(pc));
  geom_Shape_move(pc, 5.0, -5.0);
  printf("After move pos.=(%f, %f)\n", geom_Shape_get_x(pc), geom_Shape_get_y(pc));
  
  delete_geom_Square(ps);
  delete_geom_Circle(pc);
}


