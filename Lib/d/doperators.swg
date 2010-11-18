/* -----------------------------------------------------------------------------
 * doperators.swg
 *
 * Mapping of C++ operator overloading methods to D.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus

#if (SWIG_D_VERSION == 1)

%rename(opAdd) *::operator+;
%rename(opPos) *::operator+();
%rename(opAddAssign) *::operator+=;
%rename(opSub) *::operator-;
%rename(opNeg) *::operator-();
%rename(opSubAssign) *::operator-=;
%rename(opMul) *::operator*;
%rename(opMulAssign) *::operator*=;
%rename(opDiv) *::operator/;
%rename(opDivAssign) *::operator/=;
%rename(opMod) *::operator%;
%rename(opModAssign) *::operator%=;

%rename(opCom) *::operator~();
%rename(opAnd) *::operator&;
%rename(opAndAssign) *::operator&=;
%rename(opOr) *::operator|;
%rename(opOrAssign) *::operator|=;
%rename(opXor) *::operator^;
%rename(opXorAssign) *::operator^=;
%rename(opShl) *::operator<<;
%rename(opShlAssign) *::operator<<=;
%rename(opShr) *::operator>>;
%rename(opShrAssign) *::operator>>=;

%rename(opIndex) *::operator[](unsigned) const;
%rename(opIndexAssign) *::operator[](unsigned);
%rename(opCall) *::operator();

// !a is not overrideable in D1.
%ignoreoperator(LNOT) operator!;

// a != b is rewritten as !a.opEquals(b) in D.
// For now, just ignore both of them, since there would be quite a bit of magic
// needed to correctly generate a wrapper method for non-primitives types (there is
// only one opEquals overload with an Object parameter in D).
%ignoreoperator(EQ) operator==;
%ignoreoperator(NOTEQUAL) operator!=;

// opCmp is used in D.
%ignoreoperator(LT) operator<;
%ignoreoperator(LTEQUAL) operator<=;
%ignoreoperator(GT) operator>;
%ignoreoperator(GTEQUAL) operator>=;

// The logic operators are not overrideable in D.
%ignoreoperator(LAND) operator&&;
%ignoreoperator(LOR) operator||;

// ++/--a is rewritten as a +/-= 1 in D.
%ignoreoperator(PLUSPLUS) operator++();
%ignoreoperator(MINUSMINUS) operator--();
%ignoreoperator(PLUSPLUS) operator++(int);
%ignoreoperator(MINUSMINUS) operator--(int);

// The C++ assignment operator does not translate well to D where custom types
// have reference semantics.
%ignoreoperator(EQ) operator=;

#else

// Operator overloading works completely different in D2, proper support will
// probably need fairly extensive code generation support.

#endif

#endif
