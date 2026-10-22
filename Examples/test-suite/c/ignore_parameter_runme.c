#include "ignore_parameter/ignore_parameter_wrap.h"
#include <assert.h>
#include <string.h>

int main(int argc, const char *argv[]) {
  ignore_parameter_SportsCars *car;

  assert(strcmp(ignore_parameter_jaguar(200, 0), "hello") == 0);
  assert(ignore_parameter_lotus("foo", 1) == 101);
  assert(ignore_parameter_tvr("bar", 2) == 8.8);
  assert(ignore_parameter_ferrari() == 101);
  assert(ignore_parameter_called_argout_get() == 1);
  assert(ignore_parameter_called_freearg_get() == 1);
  assert(ignore_parameter_fiat(17) == 17);

  car = ignore_parameter_SportsCars_new();
  assert(strcmp(ignore_parameter_SportsCars_daimler(car, 200, 0), "hello") == 0);
  assert(ignore_parameter_SportsCars_astonmartin(car, "foo", 1) == 101);
  assert(ignore_parameter_SportsCars_bugatti(car, "bar", 2) == 8.8);
  assert(ignore_parameter_SportsCars_lamborghini(car) == 101);
  assert(ignore_parameter_SportsCars_maseratti(car, 289) == 289);
  assert(ignore_parameter_SportsCars_audi(car) == 8.8);
  ignore_parameter_SportsCars_delete(car);

  ignore_parameter_MiniCooper_delete(ignore_parameter_MiniCooper_new(200, 0));
  ignore_parameter_MorrisMinor_delete(ignore_parameter_MorrisMinor_new("baz", 0));
  ignore_parameter_FordAnglia_delete(ignore_parameter_FordAnglia_new("quux", 200));
  ignore_parameter_AustinAllegro_delete(ignore_parameter_AustinAllegro_new());
  return 0;
}
