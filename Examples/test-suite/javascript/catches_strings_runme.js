var catches_strings = require("catches_strings");

exception_thrown = false;
try {
  catches_strings.StringsThrower.charstring();
} catch (e) {
    console.log(typeof(e))
    console.log(e.constructor.name)
    console.log(typeof(e.message))
  if (!e.message.includes("charstring message"))
    throw new Error("incorrect exception message " + e.message);
  exception_thrown = true;
}
if (!exception_thrown)
  throw new Error("Should have thrown an exception");
