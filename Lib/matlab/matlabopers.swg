/* ------------------------------------------------------------
 * Overloaded operator support
 * ------------------------------------------------------------ */

#ifdef __cplusplus

// operators supported in C++, and the methods that route to them

%rename(plus)           *::operator+;
%rename(uplus)          *::operator+();
%rename(uplus)          *::operator+() const;
%rename(minus)          *::operator-;
%rename(uminus)         *::operator-();
%rename(uminus)         *::operator-() const;
%rename(mult)           *::operator*;
%rename(mrdivide)       *::operator/;
%rename(mod)            *::operator%;
// %rename(lshift)      *::operator<<;
// %rename(rshift)      *::operator>>;
%rename(TODOand)        *::operator&&; // TODO cannot rename "and"
%rename(TODOor)         *::operator||;
%rename(xor)            *::operator^;
//%rename(invert)       *::operator~;
%rename(lt)             *::operator<;
%rename(le)             *::operator<=;
%rename(gt)             *::operator>;
%rename(ge)             *::operator>=;
%rename(isequal)        *::operator==;
%rename(ne)             *::operator!=;
%rename(TODOnot)        *::operator!;
// non-standard matlab
%rename(TODOincr)       *::operator++;
%rename(TODOdecr)       *::operator--;
%rename(TODOparen)      *::operator();
%rename(TODObrace)      *::operator[];

// Ignored inplace operators
%ignoreoperator(PLUSEQ)     operator+=;
%ignoreoperator(MINUSEQ)    operator-=;
%ignoreoperator(MULEQ)      operator*=;
%ignoreoperator(DIVEQ)      operator/=;
%ignoreoperator(MODEQ)      operator%=;
%ignoreoperator(LSHIFTEQ)   operator<<=;
%ignoreoperator(RSHIFTEQ)   operator>>=;
%ignoreoperator(ANDEQ)      operator&=;
%ignoreoperator(OREQ)       operator|=;
%ignoreoperator(XOREQ)      operator^=;

// Ignored operators
%ignoreoperator(EQ)         operator=;
%ignoreoperator(ARROWSTAR)  operator->*;
%ignoreoperator(ARROW)      operator->;
// %ignoreoperator(PARENS)     operator*();
// %ignoreoperator(PARENSC)    operator*() const;

#endif /* cplusplus */
