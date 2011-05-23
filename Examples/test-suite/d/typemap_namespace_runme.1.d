module typemap_namespace_runme;

import typemap_namespace.typemap_namespace;

void main() {
  if (test1("hello") != "hello") {
    throw new Exception("test1 failed");
  }

  if (test2("hello") != "hello") {
    throw new Exception("test2 failed");
  }
}
