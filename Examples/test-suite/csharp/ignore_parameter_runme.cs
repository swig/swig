using System;
using ignore_parameterNamespace;

public class runme
{
  static void check<T>(T actual, T expected, string what) {
    if (!actual.Equals(expected))
      throw new Exception(what + " returned " + actual + ", expected " + expected);
  }

  static void Main()
  {
    check(ignore_parameter.jaguar(200, 0), "hello", "jaguar");
    check(ignore_parameter.lotus("foo", 1), 101, "lotus");
    check(ignore_parameter.tvr("bar", 2), 8.8, "tvr");
    check(ignore_parameter.ferrari(), 101, "ferrari");
    check(ignore_parameter.called_argout, 1, "called_argout");
    check(ignore_parameter.called_freearg, 1, "called_freearg");
    check(ignore_parameter.fiat(17), 17, "fiat");

    SportsCars car = new SportsCars();
    check(car.daimler(200, 0), "hello", "daimler");
    check(car.astonmartin("foo", 1), 101, "astonmartin");
    check(car.bugatti("bar", 2), 8.8, "bugatti");
    check(car.lamborghini(), 101, "lamborghini");
    check(car.maseratti(289), 289, "maseratti");
    check(car.audi(), 8.8, "audi");

    new MiniCooper(200, 0);
    new MorrisMinor("baz", 0);
    new FordAnglia("quux", 200);
    new AustinAllegro();
  }
}
