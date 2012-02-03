module allprotected_runme;

import allprotected.Klass;
import allprotected.ProtectedBase;
import std.conv : text;
import std.exception : enforce;

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
    enforce(s == "ProtectedBase", "Failed, got '" ~ s ~ "'");

    Klass k;
    void expect(string name) {
      auto kName = k.getName();
      enforce(kName == name, "Failed, expected '" ~ name ~ "' instead of '" ~
        kName ~ "'.");
    }

    k = instanceMethod(new Klass("xyz"));
    expect("xyz");

    k = instanceOverloaded(new Klass("xyz"));
    expect("xyz");

    k = instanceOverloaded(new Klass("xyz"), "abc");
    expect("abc");

    k = staticMethod(new Klass("abc"));
    expect("abc");

    k = staticOverloaded(new Klass("xyz"));
    expect("xyz");

    k = staticOverloaded(new Klass("xyz"), "abc");
    expect("abc");

    instanceMemberVariable = 30;
    int i = instanceMemberVariable;
    enforce(i == 30, text("Failed, expected ", 30, "instead of ", i));

    staticMemberVariable = 40;
    i = staticMemberVariable;
    enforce(i == 40, text("Failed, expected ", 40, "instead of ", i));

    i = staticConstMemberVariable;
    enforce(i == 20, text("Failed, expected ", 20, "instead of ", i));

    anEnum = ProtectedBase.AnEnum.EnumVal1;
    ProtectedBase.AnEnum ae = anEnum;
    enforce(ae == ProtectedBase.AnEnum.EnumVal1);
  }
}
