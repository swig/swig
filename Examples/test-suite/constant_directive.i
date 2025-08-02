%module constant_directive

// %constant and struct

#ifdef SWIGGUILE
// Suppress warning for function pointer constant which SWIG/Guile doesn't
// currently handle.
%warnfilter(SWIGWARN_TYPEMAP_CONST_UNDEF) TYPE1CFPTR1DEF_CONSTANT1;
#endif

#ifdef SWIGOCAML
%warnfilter(SWIGWARN_PARSE_KEYWORD) val;
#endif

%inline %{
#if defined(_MSC_VER)
  #pragma warning(disable : 4190) // warning C4190: 'result' has C-linkage specified, but returns UDT 'Type1' which is incompatible with C
#endif
struct Type1 {
  Type1(int val = 0) : val(val) {}
  int val;
};
enum EnumType
{
  EnumValue
};
EnumType enumValue = EnumValue;
/* Typedefs for const Type and its pointer */
typedef const Type1 Type1Const;
typedef const Type1* Type1Cptr;

/* Typedefs for function pointers returning Type1 */
typedef Type1 (*Type1Fptr)();
typedef Type1 (* const Type1Cfptr)();

/* Function returning an instance of Type1 */
Type1 getType1Instance() { return Type1(111); }
%}

%{
  static Type1 TYPE1_CONSTANT1(1);
  static Type1 TYPE1_CONST2(2);
  static Type1 TYPE1_CONST3(3);
%}

%constant Type1 TYPE1_CONSTANT1;
%constant Type1 TYPE1_CONSTANT2 = TYPE1_CONST2;
%constant Type1 *TYPE1_CONSTANT3 = &TYPE1_CONST3;
/* Typedef'ed types */
%constant Type1Const* TYPE1CONST_CONSTANT1 = &TYPE1_CONSTANT1;
%constant Type1Cptr TYPE1CPTR_CONSTANT1 = &TYPE1_CONSTANT1;
/* Function pointers */
%constant Type1 (*TYPE1FPTR1_CONSTANT1)() = getType1Instance;
%constant Type1 (* const TYPE1CFPTR1_CONSTANT1)() = getType1Instance;
/* Typedef'ed function pointers */
%constant Type1Fptr TYPE1FPTR1DEF_CONSTANT1 = getType1Instance;
%constant Type1Cfptr TYPE1CFPTR1DEF_CONSTANT1 = getType1Instance;
/* Regular constant */
%constant int TYPE_INT = 0;
%constant enum EnumType newValue = enumValue;

/* Test handling of %constant with an implicit type which SWIG can't handle. */
#pragma SWIG nowarn=SWIGWARN_PARSE_UNSUPPORTED_VALUE
%ignore ignored_int_variable;
%inline %{
int ignored_int_variable = 42;
%}
%constant unsupported_constant_value1 = &ignored_int_variable;
%constant unsupported_constant_value2 = getType1Instance;
%constant unsupported_constant_value3 = &getType1Instance;
