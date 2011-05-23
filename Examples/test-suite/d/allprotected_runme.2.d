module allprotected_runme;

import allprotected.Klass;
import allprotected.ProtectedBase;

void main() {
  auto mpb = new MyProtectedBase("MyProtectedBase");
  mpb.accessProtected();
}

class MyProtectedBase : ProtectedBase {
public:
  this(string name) {
    super(name);
  }

  void accessProtected() {
    string s = virtualMethod();
    if (s != "ProtectedBase")
      throw new Exception("Failed");

    Klass k = instanceMethod(new Klass("xyz"));
    if (k.getName() != "xyz")
      throw new Exception("Failed");

    k = instanceOverloaded(new Klass("xyz"));
    if (k.getName() != "xyz")
      throw new Exception("Failed");

    k = instanceOverloaded(new Klass("xyz"), "abc");
    if (k.getName() != "abc")
      throw new Exception("Failed");

    k = staticMethod(new Klass("abc"));
    if (k.getName() != "abc")
      throw new Exception("Failed");

    k = staticOverloaded(new Klass("xyz"));
    if (k.getName() != "xyz")
      throw new Exception("Failed");

    k = staticOverloaded(new Klass("xyz"), "abc");
    if (k.getName() != "abc")
      throw new Exception("Failed");

    instanceMemberVariable = 30;
    int i = instanceMemberVariable;
    if (i != 30)
      throw new Exception("Failed");

    staticMemberVariable = 40;
    i = staticMemberVariable;
    if (i != 40)
      throw new Exception("Failed");

    i = staticConstMemberVariable;
    if (i != 20)
      throw new Exception("Failed");

    anEnum = ProtectedBase.AnEnum.EnumVal1;
    ProtectedBase.AnEnum ae = anEnum;
    if (ae != ProtectedBase.AnEnum.EnumVal1)
      throw new Exception("Failed");
  }
}
