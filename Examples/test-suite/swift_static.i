%module swift_static
// Swift-specific test: static (class) methods and static data.
%inline %{
struct Counter {
  static int count;
  static void reset() { count = 0; }
  static int next() { return ++count; }
};
int Counter::count = 0;
%}
