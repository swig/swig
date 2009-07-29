using System;
using special_variable_functionsNamespace;

public class runme {
  static void Main() {
    Name name = new Name();
    if (special_variable_functions.testFred(name) != "none")
      throw new Exception("test failed");
    if (special_variable_functions.testJack(name) != "$specialname")
      throw new Exception("test failed");
    if (special_variable_functions.testJill(name) != "jilly")
      throw new Exception("test failed");
    if (special_variable_functions.testMary(name) != "SWIGTYPE_p_NameWrap")
      throw new Exception("test failed");
    NewName newName = NewName.factory("factoryname");
    name = newName.getStoredName();
  }
}
