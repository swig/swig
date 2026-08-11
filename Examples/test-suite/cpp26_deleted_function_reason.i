/* This testcase checks whether SWIG correctly parses the C++26 reason for a deleted function, '= delete("reason")' */
%module cpp26_deleted_function_reason

%inline %{

void oldFreeFunction() = delete("use freeFunction() instead");

int freeFunction(int i) {
  return i + 1;
}

struct Widget {
  Widget() = default;
  Widget(const Widget &) = delete("Widget is not copyable");
  Widget &operator=(const Widget &) = delete("Widget is not copyable");

  int value() const {
    return 42;
  }

  /* Concatenated string literals are a single reason */
  void oldValue() const = delete("use value() " "instead");

  static void oldFactory() = delete("no replacement");

  void overloaded(int i) {
    (void)i;
  }
  void overloaded(double d) = delete("pass an int");
};

%}
