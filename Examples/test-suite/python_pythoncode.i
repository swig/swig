%module python_pythoncode

// github issue#379 - these examples failed with 3.0.5 and earlier (at least as
// far back as 1.3.37):

struct TYPE {
%pythoncode %{
    def one():
        a = 1
# Comment XXXX
        return a
%}
};

%define %bar
%pythoncode %{
    def one():
        a = 1
        #
        return a
%}
%enddef

struct TYPE2 {
%bar
};

%{
struct TYPE { };
struct TYPE2 { };
%}


// Overriding __new__ test: https://github.com/swig/swig/pull/1357
%inline %{
class Foo {
  public:
    virtual ~Foo() {}
    Foo() {}
};

Foo* get_foo() {return new Foo();}
%}

%pythoncode %{
    print_debug = False
%}

%extend Foo {
    // Note that %pythoncode is not available with -builtin
    %pythoncode %{
    def __new__(cls, *args, **kwargs):
        if print_debug:
            print('in Foo.__new__()')
        return super(Foo, cls).__new__(cls)

    def __init__(self):
        if print_debug:
            print('in Foo.__init__()')
    %}
};
