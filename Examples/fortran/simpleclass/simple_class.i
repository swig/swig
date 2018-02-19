/* File : simple_class.i */
%module(docstring="A simple example module") simple_class

//%include "docstring.i"

%{
#include "SimpleClass.h"
%}

%{
#include <iostream>
using std::cout;
using std::endl;
%}

%fortranbegin %{
! This code is injected immediately below the SWIG auto-generated comment
%}

%inline %{
void print_pointer(int msg, const SimpleClass* ptr)
{
    cout << "F " << (msg == 0 ? "Constructed"
                   : msg == 1 ? "Releasing"
                   : msg == 2 ? "Assigning from"
                   : msg == 3 ? "Assigning to"
                              : "XXX"
                     )
        << ' ' << (ptr ? ptr->id() : -1) << endl;
}
%}


/*
 * Note: this used to be: \code
    write(0, "(a, z16)") "F Constructed ", self%swigptr
 * \endcode
 *
 * but printing pointers is not standards-compliant.
 */

%fortranappend SimpleClass::SimpleClass %{
    call print_pointer(0, self)
%}
%fortranprepend SimpleClass::~SimpleClass %{
    call print_pointer(1, self)
%}

%feature("docstring") SimpleClass %{
Simple test class.

C++ includes: SimpleClass.h
%};

%feature("docstring")  SimpleClass::double_it %{
void SimpleClass::double_it()

Multiply the value by 2.
%};

%ignore SimpleClass::operator=;

%feature("new") emit_class;
%feature("new") SimpleClass::EmitSimpleClass;

// Rename one constructor
%rename(create_SimpleClass_dbl) SimpleClass::SimpleClass(double);

%extend SimpleClass {
SimpleClass(double a, double b)
{
    return new SimpleClass(a + b);
}
}

%include "SimpleClass.h"

// Overloaded templated function instantiation
%template(action) SimpleClass::action<double>;
%template(action) SimpleClass::action<int>;


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
