module special_variable_macros_runme;

import std.exception;
import special_variable_macros.special_variable_macros;
import special_variable_macros.Name;
import special_variable_macros.NewName;
import special_variable_macros.PairIntBool;

void main() {
  auto name = new Name();
  enforce(testFred(name) == "none");
  enforce(testJack(name) == "$specialname");
  enforce(testJill(name) == "jilly");
  enforce(testMary(name) == "SWIGTYPE_p_NameWrap");
  enforce(testJim(name) == "multiname num");

  enforce(testJohn(new PairIntBool(10, false)) == 123);

  auto newName = NewName.factory("factoryname");
  enforce(newName.getStoredName().getName() == "factoryname");
}
