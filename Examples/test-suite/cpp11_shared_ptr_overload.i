%module cpp11_shared_ptr_overload

// Tests to ensure valid overloading in C++ between shared_ptr and other types result in code that compiles
// and all but the 1st overloaded method are automatically ignored/shadowed.
// Tests the 'equivalent' attribute in the 'typecheck' typemap.

%include <std_string.i>
%include <std_shared_ptr.i>

%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) UseA(std::shared_ptr<MyType> mytype);
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) UseB(int, std::shared_ptr<MyType> mytype);
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) UseC(int, std::shared_ptr<MyType> mytype, std::shared_ptr<MyType>);

%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) UseX(MyType &mytype);
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) UseY(int, MyType &mytype);
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) UseZ(int, MyType &mytype, std::shared_ptr<MyType>);

%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) Combo1;
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) Combo2;
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) Combo3;
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) Combo4;
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) Combo5;
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) Combo6;
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED,SWIGWARN_LANG_OVERLOAD_SHADOW) Combo7;

%shared_ptr(MyType);

%inline %{
#include <memory>
#include <string>
struct MyType {
  std::string val;
  MyType(std::string val = std::string()) : val(val) {}
};

// ref
std::string UseA(MyType &mytype) { return mytype.val + " ref"; }
std::string UseA(std::shared_ptr<MyType> mytype) { return mytype->val + " sharedptr"; }

std::string UseB(int, MyType &mytype) { return mytype.val + " ref"; }
std::string UseB(int, std::shared_ptr<MyType> mytype) { return mytype->val + " sharedptr"; }

std::string UseC(int, MyType &mytype, std::shared_ptr<MyType>) { return mytype.val + " ref"; }
std::string UseC(int, std::shared_ptr<MyType> mytype, std::shared_ptr<MyType>) { return mytype->val + " sharedptr"; }

// sharedptr
std::string UseX(std::shared_ptr<MyType> mytype) { return mytype->val + " sharedptr"; }
std::string UseX(MyType &mytype) { return mytype.val + " ref"; }

std::string UseY(int, std::shared_ptr<MyType> mytype) { return mytype->val + " sharedptr"; }
std::string UseY(int, MyType &mytype) { return mytype.val + " ref"; }

std::string UseZ(int, std::shared_ptr<MyType> mytype, std::shared_ptr<MyType>) { return mytype->val + " sharedptr"; }
std::string UseZ(int, MyType &mytype, std::shared_ptr<MyType>) { return mytype.val + " ref"; }

// Combo1-4
std::string Combo1(MyType mytype) { return mytype.val + "Combo1"; }
std::string Combo1(MyType *mytype) { return ""; }
std::string Combo1(std::shared_ptr<MyType> mytype) { return ""; }
std::string Combo1(std::shared_ptr<MyType>* mytype) { return ""; }

std::string Combo2(MyType *mytype) { return mytype->val + "Combo2"; }
std::string Combo2(std::shared_ptr<MyType> mytype) { return ""; }
std::string Combo2(std::shared_ptr<MyType>* mytype) { return ""; }
std::string Combo2(MyType mytype) { return ""; }

std::string Combo3(std::shared_ptr<MyType> mytype) { return mytype->val + "Combo3"; }
std::string Combo3(std::shared_ptr<MyType>* mytype) { return ""; }
std::string Combo3(MyType mytype) { return ""; }
std::string Combo3(MyType *mytype) { return ""; }

std::string Combo4(std::shared_ptr<MyType>* mytype) { return (*mytype)->val + "Combo4"; }
std::string Combo4(MyType mytype) { return ""; }
std::string Combo4(MyType *mytype) { return ""; }
std::string Combo4(std::shared_ptr<MyType> mytype) { return ""; }

// Combo5-7
std::string Combo5(MyType &mytype) { return mytype.val + "Combo5"; }
std::string Combo5(MyType *mytype) { return ""; }
std::string Combo5(std::shared_ptr<MyType> mytype) { return ""; }

std::string Combo6(MyType *mytype) { return mytype->val + "Combo6"; }
std::string Combo6(std::shared_ptr<MyType> mytype) { return ""; }
std::string Combo6(MyType &mytype) { return ""; }

std::string Combo7(std::shared_ptr<MyType> mytype) { return mytype->val + "Combo7"; }
std::string Combo7(MyType &mytype) { return ""; }
std::string Combo7(MyType *mytype) { return ""; }
%}
