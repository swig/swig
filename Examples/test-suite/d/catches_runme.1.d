module catches_runme;

import catches.catches;

void main() {
  test({ test_catches(1); }, "C++ int exception thrown, value: 1");
  test({ test_catches(2); }, "two");
  test({ test_catches(3); }, "C++ ThreeException const & exception thrown");

  test({ test_exception_specification(1); }, "C++ int exception thrown, value: 1");
  test({ test_exception_specification(2); }, "unknown exception");
  test({ test_exception_specification(3); }, "unknown exception");

  test({ test_catches_all(1); }, "unknown exception");
}

void test(void delegate() command, char[] expectedMessage) {
  bool didntThrow;
  try {
    command();
    didntThrow = true;
  } catch (Exception e) {
    if (e.msg != expectedMessage) {
      throw new Exception("Failed to propagate C++ exception. Expected '" ~
	expectedMessage ~ "', but received '" ~ e.msg ~ "'.");
    }
  }

  if (didntThrow) {
    throw new Exception("Failed to propagate C++ exception. Expected '" ~
      expectedMessage ~ "', but no exception was thrown.");
  }
}
