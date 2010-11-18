module throw_exception_runme;

import throw_exception.Foo;

void main() {
  test!("test_int");
  test!("test_msg");
  test!("test_cls");
  test!("test_cls_ptr");
  test!("test_cls_ref");
  test!("test_cls_td");
  test!("test_cls_ptr_td");
  test!("test_cls_ref_td");
  test!("test_array");
  test!("test_enum");
}

void test(char[] methodName)() {
  auto foo = new Foo();

  bool didntThrow;
  try {
    mixin("foo." ~ methodName ~ "();");
    didntThrow = true;
  } catch (Exception) {}

  if (didntThrow) {
    throw new Exception(methodName ~ " failed");
  }
}
