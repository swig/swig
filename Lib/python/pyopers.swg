/* ------------------------------------------------------------
 * Overloaded operator support

 The directives in this file apply whether or not you use the
 -builtin option to SWIG, but operator overloads are particularly
 attractive when using -builtin, because they are much faster
 than named methods.

 If you're using the -builtin option to SWIG, and you want to define
 python operator overloads beyond the defaults defined in this file,
 here's what you need to know:

 There are two ways to define a python slot function: dispatch to a
 statically defined function; or dispatch to a method defined on the
 operand.

 To dispatch to a statically defined function, use %feature("python:<slot>"),
 where <slot> is the name of a field in a PyTypeObject, PyNumberMethods,
 PyMappingMethods, PySequenceMethods, or PyBufferProcs.  For example:

   %feature("python:tp_hash") MyClass "myHashFunc";

   class MyClass {
     public:
       ...
   };

   %{
     // Note: Py_hash_t was introduced in Python 3.2
     static Py_hash_t myHashFunc(PyObject *pyobj) {
       MyClass *cobj;
       // Convert pyobj to cobj
       return (cobj->field1 * (cobj->field2 << 7));
     }
   %}

 NOTE: It is the responsibility of the programmer (that's you) to ensure
 that a statically defined slot function has the correct signature.

 If, instead, you want to dispatch to an instance method, you can
 use %feature("python:slot").  For example:

   %feature("python:slot", "tp_hash", functype="hashfunc") MyClass::myHashFunc;

   class MyClass {
     public:
       Py_hash_t myHashFunc () const;
       ...
   };

 NOTE: Some python slots use a method signature which does not
 match the signature of SWIG-wrapped methods.  For those slots,
 SWIG will automatically generate a "closure" function to re-marshall
 the arguments before dispatching to the wrapped method.  Setting
 the "functype" attribute of the feature enables SWIG to generate
 a correct closure function.

 --------------------------------------------------------------

 The tp_richcompare slot is a special case: SWIG automatically generates
 a rich compare function for all wrapped types.  If a type defines C++
 operator overloads for comparison (operator==, operator<, etc.), they
 will be called from the generated rich compare function.  If you
 want to explicitly choose a method to handle a certain comparison
 operation, you may use a different feature, %feature("python:compare")
 like this:

   %feature("python:compare", "Py_LT") MyClass::lessThan;

   class MyClass {
     public:
       bool lessThan(const MyClass& other) const;
       ...
   };
   
 ... where "Py_LT" is one of the rich comparison opcodes defined in the
 python header file object.h.

 If there's no method defined to handle a particular comparison operation,
 the default behavior is to compare pointer values of the wrapped
 C++ objects.

 --------------------------------------------------------------


 For more information about python slots, including their names and
 signatures, you may refer to the python documentation :

   http://docs.python.org/c-api/typeobj.html

 * ------------------------------------------------------------ */


#ifdef __cplusplus

#if defined(SWIGPYTHON_BUILTIN)
#define %pybinoperator(pyname,oper,functp,slt) %rename(pyname) oper; %pythonmaybecall oper; %feature("python:slot", #slt, functype=#functp) oper; %feature("python:slot", #slt, functype=#functp) pyname;
#define %pycompare(pyname,oper,comptype) %rename(pyname) oper; %pythonmaybecall oper; %feature("python:compare", #comptype) oper; %feature("python:compare", #comptype) pyname;
#else
#define %pybinoperator(pyname,oper,functp,slt) %rename(pyname) oper; %pythonmaybecall oper
#define %pycompare(pyname,oper,comptype) %pybinoperator(pyname,oper,,comptype)
#endif

%pybinoperator(__add__,      *::operator+,		binaryfunc, nb_add);
%pybinoperator(__pos__,      *::operator+(),		unaryfunc, nb_positive);
%pybinoperator(__pos__,      *::operator+() const,	unaryfunc, nb_positive);
%pybinoperator(__sub__,      *::operator-,		binaryfunc, nb_subtract);
%pybinoperator(__neg__,      *::operator-(),		unaryfunc, nb_negative);
%pybinoperator(__neg__,      *::operator-() const,	unaryfunc, nb_negative);
%pybinoperator(__mul__,      *::operator*,		binaryfunc, nb_multiply);
%pybinoperator(__mod__,      *::operator%,		binaryfunc, nb_remainder);
%pybinoperator(__lshift__,   *::operator<<,		binaryfunc, nb_lshift);
%pybinoperator(__rshift__,   *::operator>>,		binaryfunc, nb_rshift);
%pybinoperator(__and__,      *::operator&,		binaryfunc, nb_and);
%pybinoperator(__or__,       *::operator|,		binaryfunc, nb_or);
%pybinoperator(__xor__,      *::operator^,		binaryfunc, nb_xor);
%pycompare(__lt__,           *::operator<,		Py_LT);
%pycompare(__le__,           *::operator<=,		Py_LE);
%pycompare(__gt__,           *::operator>,		Py_GT);
%pycompare(__ge__,           *::operator>=,		Py_GE);
%pycompare(__eq__,           *::operator==,		Py_EQ);
%pycompare(__ne__,           *::operator!=,		Py_NE);

/* Special cases */
%rename(__invert__)     *::operator~;
%feature("python:slot", "nb_invert", functype="unaryfunc") *::operator~;
%rename(__call__)       *::operator();
%feature("python:slot", "tp_call", functype="ternarycallfunc") *::operator();

#if defined(SWIGPYTHON_BUILTIN)
%pybinoperator(__nonzero__,   *::operator bool,		inquiry, nb_nonzero);
%pybinoperator(__truediv__,   *::operator/    ,		binaryfunc, nb_divide);
#else
%feature("shadow")      *::operator bool %{
def __nonzero__(self):
    return $action(self)
__bool__ = __nonzero__
%};
%rename(__nonzero__)    *::operator bool;
%feature("shadow")      *::operator/ %{
def __truediv__(self, *args):
    return $action(self, *args)
__div__ = __truediv__
%};
%rename(__truediv__)    *::operator/;
%pythonmaybecall        *::operator/;
#endif

/* Ignored operators */
%ignoreoperator(LNOT)       operator!;
%ignoreoperator(LAND)       operator&&;
%ignoreoperator(LOR)        operator||;
%ignoreoperator(EQ)         *::operator=;
%ignoreoperator(PLUSPLUS)   *::operator++;
%ignoreoperator(MINUSMINUS) *::operator--;
%ignoreoperator(ARROWSTAR)  *::operator->*;
%ignoreoperator(INDEX)      *::operator[];

/*
  Inplace operator declarations.

  They translate the inplace C++ operators (+=, -=, ...)  into the
  corresponding python equivalents (__iadd__, __isub__), etc.

  These operators return a reference to *this, so the underlying C++
  object is the same before and after the call.  SWIG therefore keeps
  the input 'this' pointer owned by the original Python wrapper and
  returns the same pointer without taking new ownership — both
  %delobject and %newobject are deliberately omitted.

  The old behaviour (SWIG 4.x and earlier) used %delobject and
  %newobject, which disabled ownership on the input and claimed
  ownership on the output.  Since both wrappers pointed at the same
  C++ object this caused use-after-free / double-free when the
  original wrapper outlived the returned wrapper (issue #3309).
  If you relied on the old behaviour you can restore it per class:

    %feature("del","1") A::operator+=;
    %feature("new","1") A::operator+=;

  or globally for a given operator:

    %feature("del","1") *::operator+=;
    %feature("new","1") *::operator+=;
*/

/*
 * Inplace operator macros.
 *
 * For builtin mode: rename the C++ operator and register its Python slot.
 * For non-builtin mode: rename and add a shadow that calls the C wrapper
 * then returns self, keeping the original Python wrapper alive and owning.
 * Without this, the returned wrapper (no ownership) would leave the C++
 * object orphaned when the original wrapper gets rebound (issue #3309).
 */
#if defined(SWIGPYTHON_BUILTIN)
#define %pyinplaceoper(SwigPyOper, Oper, functp, slt) %feature("python:slot", #slt, functype=#functp) Oper; %rename(SwigPyOper) Oper
#else
#define %pyinplaceoper(SwigPyOper, Oper, functp, slt) %rename(SwigPyOper) Oper
#endif

%pyinplaceoper(__iadd__   , *::operator +=,	binaryfunc, nb_inplace_add);
%pyinplaceoper(__isub__   , *::operator -=,	binaryfunc, nb_inplace_subtract);
%pyinplaceoper(__imul__   , *::operator *=,	binaryfunc, nb_inplace_multiply);
%pyinplaceoper(__imod__   , *::operator %=,	binaryfunc, nb_inplace_remainder);
%pyinplaceoper(__iand__   , *::operator &=,	binaryfunc, nb_inplace_and);
%pyinplaceoper(__ior__    , *::operator |=,	binaryfunc, nb_inplace_or);
%pyinplaceoper(__ixor__   , *::operator ^=,	binaryfunc, nb_inplace_xor);
%pyinplaceoper(__ilshift__, *::operator <<=,	binaryfunc, nb_inplace_lshift);
%pyinplaceoper(__irshift__, *::operator >>=,	binaryfunc, nb_inplace_rshift);

#ifndef SWIGPYTHON_BUILTIN
/* Shadow features for inplace operators: call the C wrapper and return self.
   The __idiv__ / __itruediv__ aliases are kept for backward compatibility. */
%feature("shadow") *::operator += %{
def __iadd__(self, *args):
    $action(self, *args)
    return self
%};
%feature("shadow") *::operator -= %{
def __isub__(self, *args):
    $action(self, *args)
    return self
%};
%feature("shadow") *::operator *= %{
def __imul__(self, *args):
    $action(self, *args)
    return self
%};
%feature("shadow") *::operator %= %{
def __imod__(self, *args):
    $action(self, *args)
    return self
%};
%feature("shadow") *::operator &= %{
def __iand__(self, *args):
    $action(self, *args)
    return self
%};
%feature("shadow") *::operator |= %{
def __ior__(self, *args):
    $action(self, *args)
    return self
%};
%feature("shadow") *::operator ^= %{
def __ixor__(self, *args):
    $action(self, *args)
    return self
%};
%feature("shadow") *::operator <<= %{
def __ilshift__(self, *args):
    $action(self, *args)
    return self
%};
%feature("shadow") *::operator >>= %{
def __irshift__(self, *args):
    $action(self, *args)
    return self
%};
%feature("shadow") *::operator /= %{
def __itruediv__(self, *args):
    $action(self, *args)
    return self
__idiv__ = __itruediv__
%};
#endif

#if defined(SWIGPYTHON_BUILTIN)
%pyinplaceoper(__itruediv__   , *::operator /=,	binaryfunc, nb_inplace_divide);
#else
%rename(__itruediv__)    *::operator /=;
#endif

/* Finally, in python we need to mark the binary operations to fail as
 'maybecall' methods */

#define %pybinopermaybecall(oper) %pythonmaybecall __ ## oper ## __;  %pythonmaybecall __r ## oper ## __

%pybinopermaybecall(add);
%pybinopermaybecall(pos);
%pybinopermaybecall(pos);
%pybinopermaybecall(sub);
%pybinopermaybecall(neg);
%pybinopermaybecall(neg);
%pybinopermaybecall(mul);
%pybinopermaybecall(div);
%pybinopermaybecall(truediv);
%pybinopermaybecall(mod);
%pybinopermaybecall(lshift);
%pybinopermaybecall(rshift);
%pybinopermaybecall(and);
%pybinopermaybecall(or);
%pybinopermaybecall(xor);
%pybinopermaybecall(lt);
%pybinopermaybecall(le);
%pybinopermaybecall(gt);
%pybinopermaybecall(ge);
%pybinopermaybecall(eq);
%pybinopermaybecall(ne);

#endif



