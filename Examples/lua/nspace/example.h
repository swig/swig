#ifndef _example_guardian_
#define _example_guardian_

int module_function() { return 7; }
int module_variable = 9;

namespace MyWorld {
  class World {
  public:
    World():
      world_max_count(9) {}
    int create_world() { return 17; }
    const int world_max_count; // = 9
  };
  namespace Nested {
    class Dweller {
      public:
        Dweller():
          food_count(11) {}
        enum Gender { MALE = 0, FEMALE = 1 };
        static int populate_cave() { return 19; }
        int create_cave() { return 13; }
        int food_count; // = 11
    };
  }
}

#endif
