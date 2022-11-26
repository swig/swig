/* This testcase checks whether SWIG correctly uses the new 'decltype()'
   introduced in C++11.
*/
%module cpp11_decltype

%inline %{
  class A {
  public:
    int i;
    decltype(i) j;

    auto get_number(decltype(i) a) -> decltype(i) {
      if (a==5)
        return 10;
      else
        return 0;
    }
  };
%}


// These are ignored as unable to deduce decltype for (i+j)
%ignore B::k;
%ignore B::get_number_sum;
%ignore B::get_number_address;
#pragma SWIG nowarn=SWIGWARN_CPP11_DECLTYPE

%inline %{
  class B {
  public:
    int i;
    decltype(i) j;
    decltype(i+j) k;

    auto get_number_sum(decltype(i+j) a) -> decltype(i+j) {
      return i+j;
    }

    auto get_number_address(decltype(&i) a) -> decltype(&i) {
      return &i;
    }
  };
%}
