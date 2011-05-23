module default_args_runme;

import std.exception;
import default_args.default_args;
import default_args.ConstMethods;
import default_args.EnumClass;
import default_args.Except;
import default_args.Foo;
import default_args.Klass;
import default_args.Statics;
import default_args.Tricky;

void main() {
  enforce(anonymous() == 7771, "anonymous (1) failed");
  enforce(anonymous(1234) == 1234,"anonymous (2) failed");
  enforce(booltest() == true, "booltest (1) failed");
  enforce(booltest(true) == true, "booltest (2) failed");
  enforce(booltest(false) == false, "booltest (3) failed");
  enforce((new EnumClass()).blah() == true, "EnumClass failed");
  enforce(casts1() == null, "casts1 failed");
  enforce(casts2() == "Hello", "casts2 failed");
  enforce(casts1("Ciao") == "Ciao", "casts1 not default failed");
  enforce(chartest1() == 'x', "chartest1 failed");
  enforce(chartest2() == '\0', "chartest2 failed");
  enforce(chartest1('y') == 'y', "chartest1 not default failed");
  enforce(chartest1('y') == 'y', "chartest1 not default failed");
  enforce(reftest1() == 42, "reftest1 failed");
  enforce(reftest1(400) == 400, "reftest1 not default failed");
  enforce(reftest2() == "hello", "reftest2 failed");

  // rename
  auto foo = new Foo();
  foo.newname();
  foo.newname(10);
  foo.renamed3arg(10, 10.0);
  foo.renamed2arg(10);
  foo.renamed1arg();

  // exception specifications
  enforceThrows( (){ exceptionspec(); }, "exceptionspec 1" );
  enforceThrows( (){ exceptionspec(-1); }, "exceptionspec 2" );
  enforceThrows( (){ exceptionspec(100); }, "exceptionspec 3" );

  auto ex = new Except(false);
  enforceThrows( (){ ex.exspec(); }, "exspec 1" );
  enforceThrows( (){ ex.exspec(-1); }, "exspec 2" );
  enforceThrows( (){ ex.exspec(100); }, "exspec 3" );
  enforceThrows( (){ ex = new Except(true); }, "Except constructor 1" );
  enforceThrows( (){ ex = new Except(true, -2); }, "Except constructor 2" );

  // Default parameters in static class methods
  enforce(Statics.staticmethod() == 10+20+30, "staticmethod 1 failed");
  enforce(Statics.staticmethod(100) == 100+20+30, "staticmethod 2 failed");
  enforce(Statics.staticmethod(100,200,300) == 100+200+300, "staticmethod 3 failed");

  auto tricky = new Tricky();
  enforce(tricky.privatedefault() == 200, "privatedefault failed");
  enforce(tricky.protectedint() == 2000, "protectedint failed");
  enforce(tricky.protecteddouble() == 987.654, "protecteddouble failed");
  enforce(tricky.functiondefault() == 500, "functiondefault failed");
  enforce(tricky.contrived() == 'X', "contrived failed");

  enforce(constructorcall().val == -1, "constructorcall test 1 failed");
  enforce(constructorcall(new Klass(2222)).val == 2222, "constructorcall test 2 failed");
  enforce(constructorcall(new Klass()).val == -1, "constructorcall test 3 failed");

  // const methods
  const cm = new ConstMethods();
  enforce(cm.coo() == 20, "coo test 1 failed");
  enforce(cm.coo(1.0) == 20, "coo test 2 failed");
}

private void enforceThrows(void delegate() dg, string errorMessage) {
  bool hasThrown;
  try {
    dg();
  } catch (Exception) {
    hasThrown = true;
  } finally {
    if (!hasThrown) {
      throw new Exception(errorMessage);
    }
  }
}
