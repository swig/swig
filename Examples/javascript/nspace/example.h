#ifndef _example_guardian_
#define _example_guardian_

int module_function() { return 7; }
int module_variable = 9;

void print(double) {}
void print(float) {}

void print2(float) {}

void print3(double) {}
void print3(float) {}

namespace MyWorld {
  class World {
  public:
    World() : world_max_count(9) {}
    int create_world() { return 17; }
    const int world_max_count; // = 9
  };
  namespace Nested {
    class Dweller {
      public:
        enum Gender { MALE = 0, FEMALE = 1 };
        static int count() { return 19; }
    };
  }

  void print(unsigned) {}

  void print2(unsigned) {}

  void print3(int) {}
  void print3(unsigned) {}

}


#endif
