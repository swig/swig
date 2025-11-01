%module typedef_reference

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) global_ref;

%include cpointer.i
%pointer_functions(int, intp);

%inline %{
  typedef int & IntRef;
  int somefunc(IntRef i) { return i; }
  int otherfunc(int &i) { return i; }

  typedef IntRef IntRefAgain;
  int afunc(IntRefAgain i) { return i; }
  struct RefTester {
    int int_member;
    IntRefAgain ref_int;
    RefTester(IntRefAgain i) : int_member(ref_int), ref_int(int_member) {}
    int reftester_func(IntRefAgain i) { return i; }
    static int reftester_static_func(IntRefAgain i) { return i; }
  };

  int global_int = 1234;
  IntRefAgain global_ref = global_int;;
%}
