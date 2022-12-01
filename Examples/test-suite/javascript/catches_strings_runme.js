var catches_strings = require("catches_strings");

exception_thrown = false;
try {
  catches_strings.StringsThrower.charstring();
} catch (e) {
  if (!e.message.includes("charstring message"))
    throw new Error("incorrect exception message " + e.message);
  exception_thrown = true;
}
if (!exception_thrown)
  throw new Error("Should have thrown an exception");

exception_thrown = false;
try {
  catches_strings.StringsThrower.stdstring();
} catch (e) {
  if (!e.message.includes("stdstring message"))
    throw new Error("incorrect exception message " + e.message);
  exception_thrown = true;
}
if (!exception_thrown)
  throw new Error("Should have thrown an exception");
