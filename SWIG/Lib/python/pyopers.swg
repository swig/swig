/* ------------------------------------------------------------
 * Overloaded operator support
 * ------------------------------------------------------------ */


#ifdef __cplusplus
%define %pybinoperator(pyname,oper) 
%rename(pyname) oper;
%pythonmaybecall oper;
%enddef

%pybinoperator(__add__,      *::operator+);
%pybinoperator(__pos__,      *::operator+());
%pybinoperator(__pos__,      *::operator+() const);
%pybinoperator(__sub__,      *::operator-);
%pybinoperator(__neg__,      *::operator-());
%pybinoperator(__neg__,      *::operator-() const);
%pybinoperator(__mul__,      *::operator*);
%pybinoperator(__div__,      *::operator/);
%pybinoperator(__mod__,      *::operator%);
%pybinoperator(__lshift__,   *::operator<<);
%pybinoperator(__rshift__,   *::operator>>);
%pybinoperator(__and__,      *::operator&);
%pybinoperator(__or__,       *::operator|);
%pybinoperator(__xor__,      *::operator^);
%pybinoperator(__lt__,       *::operator<);
%pybinoperator(__le__,       *::operator<=);
%pybinoperator(__gt__,       *::operator>);
%pybinoperator(__ge__,       *::operator>=);
%pybinoperator(__eq__,       *::operator==);
%pybinoperator(__ne__,       *::operator!=);

%define %pybinoperation(oper)
%pythonmaybecall __ ## oper ## __;
%pythonmaybecall __r ## oper ## __;
%enddef

%pybinoperation(add);
%pybinoperation(pos);
%pybinoperation(pos);
%pybinoperation(sub);
%pybinoperation(neg);
%pybinoperation(neg);
%pybinoperation(mul);
%pybinoperation(div);
%pybinoperation(mod);
%pybinoperation(lshift);
%pybinoperation(rshift);
%pybinoperation(and);
%pybinoperation(or);
%pybinoperation(xor);
%pybinoperation(lt);
%pybinoperation(le);
%pybinoperation(gt);
%pybinoperation(ge);
%pybinoperation(eq);
%pybinoperation(ne);


/* Special cases */
%rename(__invert__)     *::operator~;
%rename(__call__)       *::operator();

/* Ignored operators */
%ignorewarn("361:operator! ignored") operator!;
%ignorewarn("361:operator not ignored") operator not;
%ignorewarn("381:operator&& ignored") operator&&;
%ignorewarn("381:operator and ignored") operator and;
%ignorewarn("382:operator|| ignored") operator||;
%ignorewarn("382:operator or ignored") operator or;
%ignorewarn("362:operator= ignored") *::operator=;
%ignorewarn("383:operator++ ignored") *::operator++;
%ignorewarn("384:operator-- ignored") *::operator--;
%ignorewarn("386:operator->* ignored") *::operator->*;
%ignorewarn("389:operator[] ignored (consider using %extend)") *::operator[];



/*
  Inplace operator declarations.

  They translate the inplace C++ operators (+=, -=, ...)  into the
  corresponding python equivalents(__iadd__,__isub__), etc,
  disabling the ownership of the input 'self' pointer, and assigning
  it to the returning object:  

     %feature("self:disown") *::Operator;
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

     %feature("self:disown","") A::operator+=;
     %feature("new","") A::operator+=;

  which recovers the old behaviour for the class 'A', or if you are
  100% sure your entire system works fine in the old way, use:

    %feature("self:disown","") *::operator+=;
    %feature("new","") *::operator+=;

*/

%define %swig_inplace_oper(Oper, PyOper)
%feature("self:disown") *::Oper;
%feature("new") *::Oper;
%rename(__##PyOper##__) *::Oper;
%enddef

%swig_inplace_oper(operator +=,  iadd);
%swig_inplace_oper(operator -=,  isub);
%swig_inplace_oper(operator *=,  imul);
%swig_inplace_oper(operator /=,  idiv);
%swig_inplace_oper(operator %=,  imod);
%swig_inplace_oper(operator &=,  iand);
%swig_inplace_oper(operator |=,  ior);
%swig_inplace_oper(operator ^=,  ixor);
%swig_inplace_oper(operator <<=, ilshift);
%swig_inplace_oper(operator >>=, irshift);

#endif
