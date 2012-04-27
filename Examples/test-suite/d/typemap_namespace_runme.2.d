module typemap_namespace_runme;

import std.exception;
import typemap_namespace.typemap_namespace;

void main() {
  enforce(test1("hello") == "hello", "test1 failed");
  enforce(test2("hello") == "hello", "test2 failed");
}
