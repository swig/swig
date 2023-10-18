module cpp11_strongly_typed_enumerations_runme;

import cpp11_strongly_typed_enumerations.cpp11_strongly_typed_enumerations;
import cpp11_strongly_typed_enumerations.Enum1;
import cpp11_strongly_typed_enumerations.Enum2;
import cpp11_strongly_typed_enumerations.Enum3;
import cpp11_strongly_typed_enumerations.Enum4;
import cpp11_strongly_typed_enumerations.Enum5;
import cpp11_strongly_typed_enumerations.Enum6;
import cpp11_strongly_typed_enumerations.Enum7td;
import cpp11_strongly_typed_enumerations.Enum8;
import cpp11_strongly_typed_enumerations.Enum9;
import cpp11_strongly_typed_enumerations.Enum10;
import cpp11_strongly_typed_enumerations.Enum11;
import cpp11_strongly_typed_enumerations.Enum15;
import cpp11_strongly_typed_enumerations.Enum16;
import cpp11_strongly_typed_enumerations.Enum17;
import cpp11_strongly_typed_enumerations.Class1;
import cpp11_strongly_typed_enumerations.Class2;
import std.conv;

int enumCheck(int actual, int expected) {
  if (actual != expected)
    throw new Exception("Enum value mismatch. Expected " ~ to!string(expected) ~ " Actual: " ~ to!string(actual));
  return expected + 1;
}

void main() {
  int val = 0;
  val = enumCheck(cast(int)Enum1.Val1, val);
  val = enumCheck(cast(int)Enum1.Val2, val);
  val = enumCheck(cast(int)Enum1.Val3, 13);
  val = enumCheck(cast(int)Enum1.Val4, val);
  val = enumCheck(cast(int)Enum1.Val5a, 13);
  val = enumCheck(cast(int)Enum1.Val6a, val);

  val = 0;
  val = enumCheck(cast(int)Enum2.Val1, val);
  val = enumCheck(cast(int)Enum2.Val2, val);
  val = enumCheck(cast(int)Enum2.Val3, 23);
  val = enumCheck(cast(int)Enum2.Val4, val);
  val = enumCheck(cast(int)Enum2.Val5b, 23);
  val = enumCheck(cast(int)Enum2.Val6b, val);

  val = 0;
  val = enumCheck(cast(int)Enum4.Val1, val);
  val = enumCheck(cast(int)Enum4.Val2, val);
  val = enumCheck(cast(int)Enum4.Val3, 43);
  val = enumCheck(cast(int)Enum4.Val4, val);

  val = 0;
  val = enumCheck(cast(int)Enum5.Val1, val);
  val = enumCheck(cast(int)Enum5.Val2, val);
  val = enumCheck(cast(int)Enum5.Val3, 53);
  val = enumCheck(cast(int)Enum5.Val4, val);

  val = 0;
  val = enumCheck(cast(int)Enum6.Val1, val);
  val = enumCheck(cast(int)Enum6.Val2, val);
  val = enumCheck(cast(int)Enum6.Val3, 63);
  val = enumCheck(cast(int)Enum6.Val4, val);

  val = 0;
  val = enumCheck(cast(int)Enum7td.Val1, val);
  val = enumCheck(cast(int)Enum7td.Val2, val);
  val = enumCheck(cast(int)Enum7td.Val3, 73);
  val = enumCheck(cast(int)Enum7td.Val4, val);

  val = 0;
  val = enumCheck(cast(int)Enum8.Val1, val);
  val = enumCheck(cast(int)Enum8.Val2, val);
  val = enumCheck(cast(int)Enum8.Val3, 83);
  val = enumCheck(cast(int)Enum8.Val4, val);

  val = 0;
  val = enumCheck(cast(int)Enum10.Val1, val);
  val = enumCheck(cast(int)Enum10.Val2, val);
  val = enumCheck(cast(int)Enum10.Val3, 103);
  val = enumCheck(cast(int)Enum10.Val4, val);

  val = 0;
  val = enumCheck(cast(int)Class1.Enum12.Val1, 1121);
  val = enumCheck(cast(int)Class1.Enum12.Val2, 1122);
  val = enumCheck(cast(int)Class1.Enum12.Val3, val);
  val = enumCheck(cast(int)Class1.Enum12.Val4, val);
  val = enumCheck(cast(int)Class1.Enum12.Val5c, 1121);
  val = enumCheck(cast(int)Class1.Enum12.Val6c, val);

  val = 0;
  val = enumCheck(cast(int)Class1.Enum13.Val1, 1131);
  val = enumCheck(cast(int)Class1.Enum13.Val2, 1132);
  val = enumCheck(cast(int)Class1.Enum13.Val3, val);
  val = enumCheck(cast(int)Class1.Enum13.Val4, val);
  val = enumCheck(cast(int)Class1.Enum13.Val5d, 1131);
  val = enumCheck(cast(int)Class1.Enum13.Val6d, val);

  val = 0;
  val = enumCheck(cast(int)Class1.Enum14.Val1, 1141);
  val = enumCheck(cast(int)Class1.Enum14.Val2, 1142);
  val = enumCheck(cast(int)Class1.Enum14.Val3, val);
  val = enumCheck(cast(int)Class1.Enum14.Val4, val);
  val = enumCheck(cast(int)Class1.Enum14.Val5e, 1141);
  val = enumCheck(cast(int)Class1.Enum14.Val6e, val);

  /* Nested struct not supported for D
  val = 0;
  val = enumCheck(cast(int)Class1.Struct1.Enum12.Val1, 3121);
  val = enumCheck(cast(int)Class1.Struct1.Enum12.Val2, 3122);
  val = enumCheck(cast(int)Class1.Struct1.Enum12.Val3, val);
  val = enumCheck(cast(int)Class1.Struct1.Enum12.Val4, val);
  val = enumCheck(cast(int)Class1.Struct1.Enum12.Val5f, 3121);
  val = enumCheck(cast(int)Class1.Struct1.Enum12.Val6f, val);

  val = 0;
  val = enumCheck(cast(int)Class1.Struct1.Enum13.Val1, 3131);
  val = enumCheck(cast(int)Class1.Struct1.Enum13.Val2, 3132);
  val = enumCheck(cast(int)Class1.Struct1.Enum13.Val3, val);
  val = enumCheck(cast(int)Class1.Struct1.Enum13.Val4, val);

  val = 0;
  val = enumCheck(cast(int)Class1.Struct1.Enum14.Val1, 3141);
  val = enumCheck(cast(int)Class1.Struct1.Enum14.Val2, 3142);
  val = enumCheck(cast(int)Class1.Struct1.Enum14.Val3, val);
  val = enumCheck(cast(int)Class1.Struct1.Enum14.Val4, val);
  val = enumCheck(cast(int)Class1.Struct1.Enum14.Val5g, 3141);
  val = enumCheck(cast(int)Class1.Struct1.Enum14.Val6g, val);
  */

  val = 0;
  val = enumCheck(cast(int)Class2.Enum12.Val1, 2121);
  val = enumCheck(cast(int)Class2.Enum12.Val2, 2122);
  val = enumCheck(cast(int)Class2.Enum12.Val3, val);
  val = enumCheck(cast(int)Class2.Enum12.Val4, val);
  val = enumCheck(cast(int)Class2.Enum12.Val5h, 2121);
  val = enumCheck(cast(int)Class2.Enum12.Val6h, val);

  val = 0;
  val = enumCheck(cast(int)Class2.Enum13.Val1, 2131);
  val = enumCheck(cast(int)Class2.Enum13.Val2, 2132);
  val = enumCheck(cast(int)Class2.Enum13.Val3, val);
  val = enumCheck(cast(int)Class2.Enum13.Val4, val);
  val = enumCheck(cast(int)Class2.Enum13.Val5i, 2131);
  val = enumCheck(cast(int)Class2.Enum13.Val6i, val);

  val = 0;
  val = enumCheck(cast(int)Class2.Enum14.Val1, 2141);
  val = enumCheck(cast(int)Class2.Enum14.Val2, 2142);
  val = enumCheck(cast(int)Class2.Enum14.Val3, val);
  val = enumCheck(cast(int)Class2.Enum14.Val4, val);
  val = enumCheck(cast(int)Class2.Enum14.Val5j, 2141);
  val = enumCheck(cast(int)Class2.Enum14.Val6j, val);

  /* Nested struct not supported for D
  val = 0;
  val = enumCheck(cast(int)Class2.Struct1.Enum12.Val1, 4121);
  val = enumCheck(cast(int)Class2.Struct1.Enum12.Val2, 4122);
  val = enumCheck(cast(int)Class2.Struct1.Enum12.Val3, val);
  val = enumCheck(cast(int)Class2.Struct1.Enum12.Val4, val);
  val = enumCheck(cast(int)Class2.Struct1.Enum12.Val5k, 4121);
  val = enumCheck(cast(int)Class2.Struct1.Enum12.Val6k, val);

  val = 0;
  val = enumCheck(cast(int)Class2.Struct1.Enum13.Val1, 4131);
  val = enumCheck(cast(int)Class2.Struct1.Enum13.Val2, 4132);
  val = enumCheck(cast(int)Class2.Struct1.Enum13.Val3, val);
  val = enumCheck(cast(int)Class2.Struct1.Enum13.Val4, val);
  val = enumCheck(cast(int)Class2.Struct1.Enum13.Val5l, 4131);
  val = enumCheck(cast(int)Class2.Struct1.Enum13.Val6l, val);

  val = 0;
  val = enumCheck(cast(int)Class2.Struct1.Enum14.Val1, 4141);
  val = enumCheck(cast(int)Class2.Struct1.Enum14.Val2, 4142);
  val = enumCheck(cast(int)Class2.Struct1.Enum14.Val3, val);
  val = enumCheck(cast(int)Class2.Struct1.Enum14.Val4, val);
  val = enumCheck(cast(int)Class2.Struct1.Enum14.Val5m, 4141);
  val = enumCheck(cast(int)Class2.Struct1.Enum14.Val6m, val);
  */

  Class1 class1 = new Class1();
  enumCheck(cast(int)class1.class1Test1(Enum1.Val5a), 13);
  enumCheck(cast(int)class1.class1Test2(Class1.Enum12.Val5c), 1121);
  /* Nested struct not supported for D
  enumCheck(cast(int)class1.class1Test3(Class1.Struct1.Enum12.Val5f), 3121);
  */

  enumCheck(cast(int)globalTest1(Enum1.Val5a), 13);
  enumCheck(cast(int)globalTest2(Class1.Enum12.Val5c), 1121);
  /* Nested struct not supported for D
  enumCheck(cast(int)globalTest3(Class1.Struct1.Enum12.Val5f), 3121);
  */

  // Check underlying enum type
  assert(is(typeof(Enum2.Val1.asOriginalType) == short));
  assert(is(typeof(Enum4.Val1.asOriginalType) == uint));
  assert(is(typeof(Enum5.Val1.asOriginalType) == int));
  assert(is(typeof(Enum9.Val1.asOriginalType) == ushort));
  assert(is(typeof(Enum7td.Val1.asOriginalType) == uint));
  assert(is(typeof(Enum10.Val1.asOriginalType) == ubyte));

  assert(is(typeof(Enum15.Val1.asOriginalType) == short));
  assert(is(typeof(Enum16.Val1.asOriginalType) == long));
  assert(is(typeof(Enum17.Val1.asOriginalType) == uint));
}
