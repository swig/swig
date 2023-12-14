var catches_strings = require("catches_strings");

var exception_thrown = false;
try {
  /* await */(catches_strings.StringsThrower.charstring());
} catch (e) {
  if (!(e.message || e).includes("charstring message"))
    throw new Error("incorrect exception message " + e.message);
  exception_thrown = true;
}
if (!exception_thrown)
  throw new Error("Should have thrown an exception");

exception_thrown = false;
try {
  /* await */(catches_strings.StringsThrower.stdstring());
} catch (e) {
  if (!(e.message || e).includes("stdstring message"))
    throw new Error("incorrect exception message " + e.message);
  exception_thrown = true;
}
if (!exception_thrown)
  throw new Error("Should have thrown an exception");
