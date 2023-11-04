%module fortran_ownership

%{
#include "boost/shared_ptr.hpp"
%}

// Enable error handling in Fortran code
%include <exception.i>

%fortranbindc foo_counter;
%fortranbindc bar_counter;

%inline %{
extern "C" {
int foo_counter = 0;
int bar_counter = 0;
}
%}


// We aren't allowed to return a class via func-to-subroutine conversion, but we're going to test it and hide the warning
%fortransubroutine make_foo_subroutine;
%warnfilter(SWIGWARN_FORTRAN_NO_SUBROUTINE) make_foo_subroutine;

%include <boost_shared_ptr.i>
%shared_ptr(Bar)

// Automatically free class arguments passed by value
// TODO: doesn't work with shared pointers.
%fortran_autofree_rvalue(Foo)

%inline %{

struct Foo {
    int val;

    Foo(int val_) : val(val_) { ++foo_counter; }
    Foo(const Foo& other) : val(other.val) { ++foo_counter; }
    ~Foo() { --foo_counter; }
};

Foo& reference(Foo& other) { return other; }
const Foo& const_reference(const Foo& other) { return other; }
Foo make_foo(int val) { return Foo(val); }
Foo make_foo_subroutine(int val) { return Foo(val); }
Foo* get_null() { return NULL; }

int get_value(const Foo& other) { return other.val; }
int get_value_copy(Foo other) { return other.val; }

struct Bar {
    int val;

    Bar(int val_) : val(val_) { ++bar_counter; }
    Bar(const Bar& other) : val(other.val) { ++bar_counter; }
    ~Bar() { --bar_counter; }
};

boost::shared_ptr<Bar> share(boost::shared_ptr<Bar> other) { return other; }
int use_count(const boost::shared_ptr<Bar>& sp) { return sp.use_count(); }
%}

// Test that autofree mangling works with namespaced values
%fortran_autofree_rvalue(myns::Tricky)
%fortran_autofree_rvalue(myns::TemplTricky<int>)
%inline %{
namespace myns {
struct Tricky{};

template<class T>
struct TemplTricky{};

void do_nothing(Tricky) {};
void do_nothing(TemplTricky<int>) {};
}
%}

%template(TemplTrickyInt) myns::TemplTricky<int>;

// Test autofree declaration *before* including std:string
%fortran_autofree_rvalue(std::string)
namespace std {
class string {
};
}

%include <std_string.i>

%inline %{
std::string str_value(std::string s) { return s; }
const std::string& str_cref(const std::string& s) { return s; }
std::string& str_ref(std::string& s) { return s; }
%}
