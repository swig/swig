%module fortran_naming

%warnfilter(SWIGWARN_LANG_IDENTIFIER);
%warnfilter(SWIGWARN_FORTRAN_NAME_COLLISION) Omitted;
%warnfilter(SWIGWARN_FORTRAN_NAME_COLLISION) AlsoOmitted;


#ifdef SWIGFORTRAN
%fortran_struct(MyStruct);
#endif

// Without *this* line, the f_a accessors on Bar will override the _a accessors
// on _Foo, causing Fortran to fail because the argument names of the two
// setters ('arg' and 'f_a') are different.
%rename(a_bar_) Bar::a_;

// Without *these* renames, f_x and f_y will appear as duplicates in MyStruct.
%rename(m_x) MyStruct::_x;
%rename(m_y) MyStruct::_y;

%fortranconst _123;

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
    int _get_a_doubled(int two) const { return _a * two; }

    // Parameter names that are duplicates when lowercase, collide with
    // other class names, or collide with renamed args
    int sum(int num, int NuM, int FooClass, int fooclass3, int _bad) { return num + NuM + FooClass + fooclass3 + _bad; }
};

class Bar : public _Foo {
  public:
    int a_;
};

struct HasEnum {
  enum _Underscores {
      _AREBAD = 1,
  };
};

HasEnum::_Underscores get_embedded_enum_value(HasEnum::_Underscores e) { return e; }


// Test constant wrapping
#define _123 123

extern "C" {
struct MyStruct {
    float _x;
    float _y;
    float _z;
    float x_;
    float y_;
};

float get_mystruct_y(const MyStruct* ms) { return ms->_y; }
}
%}

// Forward-declare enum for SWIG: this is *not* valid C++.
enum _MyEnum;

%inline %{
// Define enum and function
enum _MyEnum {
    _MYVAL = 1,
};
int get_enum_value(_MyEnum e) { return static_cast<int>(e); }
%}

// NOTE: rename must be performed since the `_MyEnum` above was automatically renamed to `MyEnum_`
#ifdef SWIGFORTRAN
%rename(MyEnum2) MyEnum_;
%rename(MYVAL2) MYVAL_;
%fortranconst AlsoOmitted;
#endif

%inline %{
enum MyEnum_ {
    MYVAL_ = 2
};

enum Omitted {
  ZERO,
  OMITTED,
  TWO
};

enum AlsoOmitted {
  ALSOZERO,
  ALSOOMITTED,
  ALSOTWO
};

// Even though the Fortran identifier must be renamed, the function it's
// bound to cannot.
extern "C" int _0cboundfunc(const int _x) { return _x + 1; }

%}

%fortranconst;
// This name is too long
%constant int sixty_four_characters_is_way_too_long_for_fortran_or_punch_cards = 64;
// This name shows that you can't simply truncate
%constant int sixty_four_characters_is_way_too_long_for_fortran_or_punch_cardss = 65;

// This name is the maximum length but starts with an underscore
%constant int _leading_underscore_with_sixty_four_characters_is_just_darn_long = 64;
%constant int _leading_underscore_with_sixty_three_characters_might_be_tricky = 63;
%nofortranconst;

// swigc_ -prefixed name: OK if not overloaded, too long if overloaded
%inline %{
int this_is_a_very_long_name_but_its_ok_unless_its_overloaded() { return 0; }
int this_is_a_very_long_name_but_its_bad_since_its_overloaded(int i) { return i; }
float this_is_a_very_long_name_but_its_bad_since_its_overloaded(float f) { return f; }
%}

// This class is poorly named, but the symname is OK.
%inline %{
template<class T>
class _fubar {
  _fubar() { /* */ }
};
%}

%template(foobar) _fubar<int>;

// Check type-safe forward declarations
%{
struct OpaqueStruct { int i; };
struct DeclaredStruct { int i; };
struct DelayedStruct { int i; };
enum Foo { GOOD, BAD };
%}

struct DeclaredStruct;
enum Foo;

%ignore IgnoredStruct;

%inline %{
struct IgnoredStruct { int i; };
template<class T>
struct TemplatedStruct { T i; };
%}

%template() TemplatedStruct<int>;

%inline %{
  OpaqueStruct make_opaque_value(int i) {
    OpaqueStruct os;
    os.i = i;
    return os;
  }
  int get_opaque_value(OpaqueStruct o) { return o.i; }
  OpaqueStruct *get_opaque_ptr(OpaqueStruct * o) { return o; }
  const OpaqueStruct *get_opaque_cptr(const OpaqueStruct *o) { return o; }
  OpaqueStruct &get_opaque_ref(OpaqueStruct & o) { return o; }
  const OpaqueStruct &get_opaque_cref(const OpaqueStruct &o) { return o; }
  OpaqueStruct const ** get_opaque_handle() {
    static const OpaqueStruct* os = NULL;
    return &os;
  }

  int get_declared_value(const DeclaredStruct &o) { return o.i; }
  DeclaredStruct make_declared(int i) {
    DeclaredStruct o;
    o.i = i;
    return o;
  }
  int get_ignored_value(const IgnoredStruct &o) { return o.i; }
  IgnoredStruct make_ignored(int i) {
    IgnoredStruct o;
    o.i = i;
    return o;
  }
  int get_templated_value(const TemplatedStruct<int> &o) { return o.i; }
  TemplatedStruct<int> make_templated(int i) {
    TemplatedStruct<int> o;
    o.i = i;
    return o;
  }
  int get_value(Foo f) { return static_cast<int>(f); }
  DelayedStruct make_delayed(int i) {
    DelayedStruct o;
    o.i = i;
    return o;
  }
%}

struct DelayedStruct { int i; };

// Test with namespaces, and duplicates
%rename ns::identity_ptr ns_identity_ptr;
%rename ns::_Foo _ns_Foo;
%rename ns::_MyEnum _ns_MyEnum;
%rename ns::_MYVAL _ns_MYVAL;
%rename ns::get_enum_value ns_get_enum_value;

%inline %{
namespace ns {
// Forward-declare and operate on pointer
class _Foo;
class _Unused;
} // end namespace ns

namespace ns {
_Foo* identity_ptr(_Foo* f) { return f; }

// Define the class
class _Foo {
};

// Define enum and function
enum _MyEnum {
    _MYVAL = 3,
};
int get_enum_value(_MyEnum e) { return static_cast<int>(e); }
} // end namespace ns

// Test name conflicts between classes and variables
struct AA;
struct BB;

int aa_bb(AA aa, BB bb);
int aa_bb_switched(AA bb, BB aa);

struct AA { int v; };
struct BB { int v; };

%} // end inline

%{
int aa_bb(AA aa, BB bb) { return aa.v + bb.v; }
int aa_bb_switched(AA bb, BB aa) { return aa.v + bb.v; }
%}
