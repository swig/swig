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



/* Special cases */
%rename(__invert__)     *::operator~;
%rename(__call__)       *::operator();

/* Ignored operators */
%ignorewarn("361:operator! ignored") operator!;
%ignorewarn("381:operator&& ignored") operator&&;
%ignorewarn("382:operator|| ignored") operator||;
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

%define %pyinplaceoper(PyOper, Oper)
%feature("self:disown") Oper;
%feature("new") Oper;
%rename(PyOper) Oper;
%enddef

%pyinplaceoper(__iadd__   , *::operator +=);
%pyinplaceoper(__isub__   , *::operator -=);
%pyinplaceoper(__imul__   , *::operator *=);
%pyinplaceoper(__idiv__   , *::operator /=);
%pyinplaceoper(__imod__   , *::operator %=);
%pyinplaceoper(__iand__   , *::operator &=);
%pyinplaceoper(__ior__    , *::operator |=);
%pyinplaceoper(__ixor__   , *::operator ^=);
%pyinplaceoper(__ilshift__, *::operator <<=);
%pyinplaceoper(__irshift__, *::operator >>=);



/* C++ operator aliases */

%ignorewarn("381:operator and ignored")    operator and;     // `and'     `&&'
%ignorewarn("361:operator not ignored")    operator not;     // `not'     `!'
%ignorewarn("382:operator or ignored")     operator or;	     // `or'      `||'
%pyinplaceoper(__iand__,                *::operator and_eq); // `and_eq'  `&='
%pybinoperator(__and__,                 *::operator bitand)  // `bitand'  `&'
%pybinoperator(__or__,                  *::operator bitor);  // `bitor'   `|'
%rename(__invert__)                     *::operator compl;   // `compl'   `~'
%pybinoperator(__ne__,                  *::operator not_eq); // `not_eq'  `!='
%pyinplaceoper(__ior__,                 *::operator or_eq);  // `or_eq'   `|='
%pybinoperator(__xor__,                 *::operator xor);    // `xor'     `^'
%pyinplaceoper(__ixor__,                *::operator xor_eq); // `xor_eq'  `^='


/* Finally, in python we need to mark the binary operations to fail as
 'maybecall' methods */

%define %pybinopermaybecall(oper)
%pythonmaybecall __ ## oper ## __;
%pythonmaybecall __r ## oper ## __;
%enddef

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



