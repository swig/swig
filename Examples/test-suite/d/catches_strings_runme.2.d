module catches_strings_runme;

import catches_strings.catches_strings;
import catches_strings.StringsThrower;
import std.algorithm;

void main() {
  {
    bool exception_thrown = false;
    try {
      StringsThrower.charstring();
    } catch (Exception e) {
      if (!canFind(e.msg, "charstring message"))
        throw new Exception("incorrect exception message:" ~ e.msg);
      exception_thrown = true;
    }
    if (!exception_thrown)
      throw new Exception("Should have thrown an exception");
  }
  {
    bool exception_thrown = false;
    try {
      StringsThrower.stdstring();
    } catch (Exception e) {
      if (!canFind(e.msg, "stdstring message"))
        throw new Exception("incorrect exception message:" ~ e.msg);
      exception_thrown = true;
    }
    if (!exception_thrown)
      throw new Exception("Should have thrown an exception");
  }
}
