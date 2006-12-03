%module special_variables

// will fail to compile if $symname is not expanded
%typemap(argout) int i {
  $symname(99);
}

%{
#define KKK_testmethod testmethod
#define KKK_teststaticmethod KKK::teststaticmethod
%}

%inline %{
void testmethod(int i) {}
struct KKK {
  void testmethod(int i) {}
  static void teststaticmethod(int i) {}
};
%}

