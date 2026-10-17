module swig_exception_default_runme;

import swig_exception_default.swig_exception_default;

void main() {
  if (positive_only(1) != 1)
    throw new Exception("positive_only(1) failed");
  test({ positive_only(0); }, "Expected a positive value.");

  if (positive_result(1) != 1)
    throw new Exception("positive_result(1) failed");
  test({ positive_result(0); }, "Expected a positive result.");
}

void test(void delegate() command, string expectedMessage) {
  bool didntThrow;
  try {
    command();
    didntThrow = true;
  } catch (Exception e) {
    if (e.msg != expectedMessage)
      throw new Exception("Expected '" ~ expectedMessage ~ "', but received '" ~ e.msg ~ "'.");
  }

  if (didntThrow)
    throw new Exception("Expected '" ~ expectedMessage ~ "', but no exception was thrown.");
}
