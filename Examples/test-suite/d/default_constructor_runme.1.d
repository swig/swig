module default_constructor_runme;

import default_constructor.G;

void main() {
  // Protected destructor test.
  try {
    {
      scope g = new G();
    }
    throw new Exception("Protected destructor exception should have been thrown");
  } catch (Exception e) {
    if (e.msg != "C++ destructor does not have public access") {
      throw e;
    }
  }
}
