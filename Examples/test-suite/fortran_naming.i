%module fortran_naming

%warnfilter(SWIGWARN_LANG_IDENTIFIER);

%fortran_bindc_struct(MyStruct);

%inline %{
// Forward-declare and operate on pointer
class _Foo;
_Foo* identity_ptr(_Foo* f) { return f; }

// Define the class
class _Foo {
  public:
    int _a;
    int _b;
    int _get_a_doubled() const { return _a * 2; }
};

class Bar : public _Foo {
  public:
    int f_a;
};

enum _MyEnum {
    _MYVAL = 1,
};

extern "C" {
struct MyStruct {
    float _x;
    float _y;
    float _z;
/*
 * DANGER: the following variables would be ignored, causing the C-bound struct
 * to not match the Fortran definition. The same effect could be achieved with
 * %ignore MyStruct::f_x; .
 *
 * TODO: check all member variables of a bind-c struct to make sure they're not ignored
 */
    float f_x;
    float f_y;
};

float get_mystruct_y(const MyStruct* ms) { return ms->_y; }
}
%}

%warnfilter(SWIGWARN_PARSE_REDEFINED) f_MyEnum;
%warnfilter(SWIGWARN_PARSE_REDEFINED) f_MYVAL;

// NOTE: these will be ignored because the previous enum will be renamed.
// This behavior is consistent with the other SWIG target languages.
%inline %{
enum f_MyEnum {
    f_MYVAL = 2
};

// Even though the Fortran identifier must be renamed, the function it's
// bound to cannot.
extern "C" int _cboundfunc(const int* _x) { return *_x + 1; }

%}
