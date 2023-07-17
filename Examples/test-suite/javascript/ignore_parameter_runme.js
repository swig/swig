const ignore_parameter = require('ignore_parameter');

function check(a, b) {
  if (a !== b) throw new Error(`'${a}' != '${b}`);
}

check(/* await */(ignore_parameter.jaguar(200, 0)), "hello");
check(/* await */(ignore_parameter.lotus("foo", 1)), 101);
check(/* await */(ignore_parameter.tvr("bar", 2)), 8.8);
check(/* await */(ignore_parameter.ferrari()), 101);
check(/* await */(ignore_parameter.fiat(17)), 17);

car = new ignore_parameter.SportsCars();
check(/* await */(car.daimler(200, 0)), "hello");
check(/* await */(car.astonmartin("foo", 1)), 101);
check(/* await */(car.bugatti("bar", 2)), 8.8);
check(/* await */(car.lamborghini()), 101);
check(/* await */(car.maseratti(289)), 289);
check(/* await */(car.audi()), 8.8);

new ignore_parameter.MiniCooper(200, 0);
new ignore_parameter.MorrisMinor("baz", 0);
new ignore_parameter.FordAnglia("quux", 200);
new ignore_parameter.AustinAllegro();
