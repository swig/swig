module default_args_runme;

import default_args.default_args;
import default_args.ConstMethods;
import default_args.EnumClass;
import default_args.Except;
import default_args.Foo;
import default_args.Klass;
import default_args.Statics;
import default_args.Tricky;

void main() {
  if (anonymous() != 7771)
    throw new Exception("anonymous (1) failed");
  if (anonymous(1234) != 1234)
    throw new Exception("anonymous (2) failed");

  if (booltest() != true)
    throw new Exception("booltest (1) failed");
  if (booltest(true) != true)
    throw new Exception("booltest (2) failed");
  if (booltest(false) != false)
    throw new Exception("booltest (3) failed");

  auto ec = new EnumClass();
  if (ec.blah() != true)
    throw new Exception("EnumClass failed");

  if (casts1() != null)
    throw new Exception("casts1 failed");

  if (casts2() != "Hello")
    throw new Exception("casts2 failed");

  if (casts1("Ciao") != "Ciao")
    throw new Exception("casts1 not default failed");

  if (chartest1() != 'x')
    throw new Exception("chartest1 failed");

  if (chartest2() != '\0')
    throw new Exception("chartest2 failed");

  if (chartest1('y') != 'y')
    throw new Exception("chartest1 not default failed");

  if (chartest1('y') != 'y')
    throw new Exception("chartest1 not default failed");

  if (reftest1() != 42)
    throw new Exception("reftest1 failed");

  if (reftest1(400) != 400)
    throw new Exception("reftest1 not default failed");

  if (reftest2() != "hello")
    throw new Exception("reftest2 failed");

  // rename
  auto foo = new Foo();
  foo.newname();
  foo.newname(10);
  foo.renamed3arg(10, 10.0);
  foo.renamed2arg(10);
  foo.renamed1arg();

  // exception specifications
  testException( { exceptionspec(); }, "exceptionspec 1" );
  testException( { exceptionspec(-1); }, "exceptionspec 2" );
  testException( { exceptionspec(100); }, "exceptionspec 3" );

  auto ex = new Except(false);
  testException( { ex.exspec(); }, "exspec 1" );
  testException( { ex.exspec(-1); }, "exspec 2" );
  testException( { ex.exspec(100); }, "exspec 3" );
  testException( { ex = new Except(true); }, "Except constructor 1" );
  testException( { ex = new Except(true, -2); }, "Except constructor 2" );

  // Default parameters in static class methods
  if (Statics.staticmethod() != 10+20+30)
    throw new Exception("staticmethod 1 failed");
  if (Statics.staticmethod(100) != 100+20+30)
    throw new Exception("staticmethod 2 failed");
  if (Statics.staticmethod(100,200,300) != 100+200+300)
    throw new Exception("staticmethod 3 failed");


  auto tricky = new Tricky();
  if (tricky.privatedefault() != 200)
    throw new Exception("privatedefault failed");
  if (tricky.protectedint() != 2000)
    throw new Exception("protectedint failed");
  if (tricky.protecteddouble() != 987.654)
    throw new Exception("protecteddouble failed");
  if (tricky.functiondefault() != 500)
    throw new Exception("functiondefault failed");
  if (tricky.contrived() != 'X')
    throw new Exception("contrived failed");

  if (constructorcall().val != -1)
    throw new Exception("constructorcall test 1 failed");

  if (constructorcall(new Klass(2222)).val != 2222)
    throw new Exception("constructorcall test 2 failed");

  if (constructorcall(new Klass()).val != -1)
    throw new Exception("constructorcall test 3 failed");

  // const methods
  auto cm = new ConstMethods();
  if (cm.coo() != 20)
    throw new Exception("coo test 1 failed");
  if (cm.coo(1.0) != 20)
    throw new Exception("coo test 2 failed");
}

void testException(void delegate() command, char[] testName) {
  bool didntThrow;
  try {
    command();
    didntThrow = true;
  } catch (Exception e) {}

  if (didntThrow) {
    throw new Exception(testName ~ " failed");
  }
}
