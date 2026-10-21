module ignore_parameter_runme;

import std.exception;
import ignore_parameter.ignore_parameter;
import ignore_parameter.AustinAllegro;
import ignore_parameter.FordAnglia;
import ignore_parameter.MiniCooper;
import ignore_parameter.MorrisMinor;
import ignore_parameter.SportsCars;

void main() {
  enforce(jaguar(200, 0) == "hello", "jaguar failed");
  enforce(lotus("foo", 1) == 101, "lotus failed");
  enforce(tvr("bar", 2) == 8.8, "tvr failed");
  enforce(ferrari() == 101, "ferrari failed");
  enforce(called_argout == 1, "argout typemap not called");
  enforce(called_freearg == 1, "freearg typemap not called");
  enforce(fiat(17) == 17, "fiat failed");

  auto car = new SportsCars();
  enforce(car.daimler(200, 0) == "hello", "daimler failed");
  enforce(car.astonmartin("foo", 1) == 101, "astonmartin failed");
  enforce(car.bugatti("bar", 2) == 8.8, "bugatti failed");
  enforce(car.lamborghini() == 101, "lamborghini failed");
  enforce(car.maseratti(289) == 289, "maseratti failed");
  enforce(car.audi() == 8.8, "audi failed");

  new MiniCooper(200, 0);
  new MorrisMinor("baz", 0);
  new FordAnglia("quux", 200);
  new AustinAllegro();
}
