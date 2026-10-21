# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

ignore_parameter

function check(actual, expected, what)
  if (!isequal(actual, expected))
    error([what, " returned an unexpected value"]);
  endif
endfunction

check(jaguar(200, 0), "hello", "jaguar");
check(lotus("foo", 1), 101, "lotus");
check(tvr("bar", 2), 8.8, "tvr");
check(ferrari(), 101, "ferrari");
check(cvar.called_argout, 1, "called_argout");
check(cvar.called_freearg, 1, "called_freearg");
check(fiat(17), 17, "fiat");

car = SportsCars();
check(car.daimler(200, 0), "hello", "daimler");
check(car.astonmartin("foo", 1), 101, "astonmartin");
check(car.bugatti("bar", 2), 8.8, "bugatti");
check(car.lamborghini(), 101, "lamborghini");
check(car.maseratti(289), 289, "maseratti");
check(car.audi(), 8.8, "audi");

MiniCooper(200, 0);
MorrisMinor("baz", 0);
FordAnglia("quux", 200);
AustinAllegro();
