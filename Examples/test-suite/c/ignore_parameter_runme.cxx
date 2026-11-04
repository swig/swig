#include "ignore_parameter/ignore_parameter_wrap.h"
#include <assert.h>
#include <string.h>

using namespace ignore_parameter;

int main(int argc, const char *argv[]) {
  char foo[] = "foo";
  char bar[] = "bar";
  char baz[] = "baz";
  char quux[] = "quux";

  assert(strcmp(jaguar(200, 0), "hello") == 0);
  assert(lotus(foo, 1) == 101);
  assert(tvr(bar, 2) == 8.8);
  assert(ferrari() == 101);
  assert(called_argout() == 1);
  assert(called_freearg() == 1);
  assert(fiat(17) == 17);
  assert(peugeot() == 5);

  SportsCars car;
  assert(strcmp(car.daimler(200, 0), "hello") == 0);
  assert(car.astonmartin(foo, 1) == 101);
  assert(car.bugatti(bar, 2) == 8.8);
  assert(car.lamborghini() == 101);
  assert(car.maseratti(289) == 289);
  assert(car.audi() == 8.8);

  MiniCooper mini(200, 0);
  MorrisMinor morris(baz, 0);
  FordAnglia anglia(quux, 200);
  AustinAllegro allegro;
  return 0;
}
