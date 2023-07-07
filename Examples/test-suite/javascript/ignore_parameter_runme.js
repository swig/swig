const ignore_parameter = require('ignore_parameter');

function check(a, b, argout) {
  if (a !== b) throw new Error(`'${a}' != '${b}`);
  if (argout) {
    if (ignore_parameter.called_argout !== 1)
      throw new Error('argout typemap not applied');
  }
}

check(ignore_parameter.jaguar(200, 0), "hello");
check(ignore_parameter.lotus("foo", 1), 101, true);
check(ignore_parameter.tvr("bar", 2), 8.8);
check(ignore_parameter.ferrari(), 101, true);
check(ignore_parameter.fiat(17), 17);

car = new ignore_parameter.SportsCars();
check(car.daimler(200, 0), "hello");
check(car.astonmartin("foo", 1), 101, true);
check(car.bugatti("bar", 2), 8.8);
check(car.lamborghini(), 101, true);
check(car.maseratti(289), 289);
check(car.audi(), 8.8);

new ignore_parameter.MiniCooper(200, 0);
new ignore_parameter.MorrisMinor("baz", 0);
new ignore_parameter.FordAnglia("quux", 200);
new ignore_parameter.AustinAllegro();
