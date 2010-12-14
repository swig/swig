/* ------------------------------------------------------------
 * Overloaded operator support
 * ------------------------------------------------------------ */


#ifdef __cplusplus

#if defined(SWIGPYTHON_BUILTIN)
#define %pybinoperator(pyname,oper,functp,slot) %rename(pyname) oper; %pythonmaybecall oper; %feature("pyslot", #slot, functype=#functp) oper;
#define %pycompare(pyname,oper,comptype) %rename(pyname) oper; %pythonmaybecall oper; %feature("pycompare", #comptype) oper;
#else
#define %pybinoperator(pyname,oper,functp,slot) %rename(pyname) oper; %pythonmaybecall oper
#define %pycompare(pyname,oper,comptype) %pybinoperator(pyname,oper,,comptype)
#endif

%pybinoperator(__add__,      *::operator+,		binary_func, nb_add);
%pybinoperator(__pos__,      *::operator+(),		unary_func, nb_positive);
%pybinoperator(__pos__,      *::operator+() const,	unary_func, nb_positive);
%pybinoperator(__sub__,      *::operator-,		binary_func, nb_subtract);
%pybinoperator(__neg__,      *::operator-(),		unary_func, nb_negative);
%pybinoperator(__neg__,      *::operator-() const,	unary_func, nb_negative);
%pybinoperator(__mul__,      *::operator*,		binary_func, nb_multiply);
%pybinoperator(__div__,      *::operator/,		binary_func, nb_div);
%pybinoperator(__mod__,      *::operator%,		binary_func, nb_remainder);
%pybinoperator(__lshift__,   *::operator<<,		binary_func, nb_lshift);
%pybinoperator(__rshift__,   *::operator>>,		binary_func, nb_rshift);
%pybinoperator(__and__,      *::operator&,		binary_func, nb_and);
%pybinoperator(__or__,       *::operator|,		binary_func, nb_or);
%pybinoperator(__xor__,      *::operator^,		binary_func, nb_xor);
%pycompare(__lt__,           *::operator<,		Py_LT);
%pycompare(__le__,           *::operator<=,		Py_LE);
%pycompare(__gt__,           *::operator>,		Py_GT);
%pycompare(__ge__,           *::operator>=,		Py_GE);
%pycompare(__eq__,           *::operator==,		Py_EQ);
%pycompare(__ne__,           *::operator!=,		Py_NE);

%feature("pyslot", "nb_truediv", functype="binary_func") *::operator/;

/* Special cases */
%rename(__invert__)     *::operator~;
%feature("pyslot", "nb_invert", functype="unary_func") *::operator~;
%rename(__call__)       *::operator();
%feature("pyslot", "tp_call", functype="ternary_func") *::operator();

#if defined(SWIGPYTHON_BUILTIN)
%pybinoperator(__nonzero__,   *::operator bool,		unary_func, nb_nonzero);
#else
%feature("shadow")      *::operator bool %{
def __nonzero__(self):
    return $action(self)
__bool__ = __nonzero__
%};
%rename(__nonzero__)    *::operator bool;
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
  corresponding python equivalents(__iadd__,__isub__), etc,
  disabling the ownership of the input 'self' pointer, and assigning
  it to the returning object:  

     %feature("del") *::Operator;
     %feature("new") *::Operator;
  
  This makes the most common case safe, ie:

     A&  A::operator+=(int i) { ...; return *this; }
    ^^^^                                    ^^^^^^

  will work fine, even when the resulting python object shares the
  'this' pointer with the input one. The input object is usually
  deleted after the operation, including the shared 'this' pointer,
  producing 'strange' seg faults, as reported by Lucriz
  (lucriz@sitilandia.it).

  If you have an interface that already takes care of that, ie, you
  already are using inplace operators and you are not getting
  seg. faults, with the new scheme you could end with 'free' elements
  that never get deleted (maybe, not sure, it depends). But if that is
  the case, you could recover the old behaviour using

     %feature("del","") A::operator+=;
     %feature("new","") A::operator+=;

  which recovers the old behaviour for the class 'A', or if you are
  100% sure your entire system works fine in the old way, use:

    %feature("del","") *::operator+=;
    %feature("new","") *::operator+=;

*/

#if defined(SWIGPYTHON_BUILTIN)
#define %pyinplaceoper(SwigPyOper, Oper, functp, slot) %rename(SwigPyOper) Oper; %feature("pyslot", #slot, functype=#functp) Oper;
#else
#define %pyinplaceoper(SwigPyOper, Oper, functp, slot) %delobject Oper; %newobject Oper; %rename(SwigPyOper) Oper
#endif

%pyinplaceoper(__iadd__   , *::operator +=,	binary_func, nb_inplace_add);
%pyinplaceoper(__isub__   , *::operator -=,	binary_func, nb_inplace_subtract);
%pyinplaceoper(__imul__   , *::operator *=,	binary_func, nb_inplace_multiply);
%pyinplaceoper(__idiv__   , *::operator /=,	binary_func, nb_inplace_divide);
%pyinplaceoper(__imod__   , *::operator %=,	binary_func, nb_inplace_remainder);
%pyinplaceoper(__iand__   , *::operator &=,	binary_func, nb_inplace_and);
%pyinplaceoper(__ior__    , *::operator |=,	binary_func, nb_inplace_or);
%pyinplaceoper(__ixor__   , *::operator ^=,	binary_func, nb_inplace_xor);
%pyinplaceoper(__ilshift__, *::operator <<=,	binary_func, nb_inplace_lshift);
%pyinplaceoper(__irshift__, *::operator >>=,	binary_func, nb_inplace_rshift);


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



