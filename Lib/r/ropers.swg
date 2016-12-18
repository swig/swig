#ifdef __cplusplus

%rename(MemberPlusPlus)     *::operator++;
%rename(MemberMinMin)       *::operator--;
%rename(MemberAdd)          *::operator+;
%rename(MemberSub)          *::operator-;
%rename(MemberNeg)          *::operator-();
%rename(MemberNegConst)     *::operator-() const;
%rename(MemberMul)          *::operator*;
%rename(MemberDiv)          *::operator/;
%rename(MemberEq)           *::operator==;
%rename(MemberNotEq)        *::operator!=;
%rename(MemberMod)          *::operator%;
%rename(MemberGreater)      *::operator>;
%rename(MemberLess)         *::operator<;
%rename(MemberNot)          *::operator!;
%rename(MemberLShift)       *::operator<<;
%rename(MemberRShift)       *::operator>>;
%rename(MemberAnd)          *::operator&;
%rename(MemberOr)           *::operator|;
%rename(MemberXor)          *::operator^;
%rename(MemberInvert)       *::operator~;
%rename(MemberLessOrEq)     *::operator<=;
%rename(MemberGreaterOrEq)  *::operator>=;
%rename(MemberCall)         *::operator();
%rename(MemberGetItem)      *::operator[];
%rename(MemberAssign)       *::operator=;
%rename(MemberArrowStar)    *::operator->*;

%rename(Equal) operator =;
%rename(PlusEqual) operator +=;
%rename(MinusEqual) operator -=;
%rename(MultiplyEqual) operator *=;
%rename(DivideEqual) operator /=;
%rename(PercentEqual) operator %=;
%rename(Plus) operator +;
%rename(Minus) operator -;
%rename(Multiply) operator *;
%rename(Divide) operator /;
%rename(Percent) operator %;
%rename(Not) operator !;
%rename(IndexIntoConst) operator[](unsigned idx) const;
%rename(IndexInto) operator[](unsigned idx);
%rename(Functor) operator ();
%rename(EqualEqual) operator ==;
%rename(NotEqual) operator !=;
%rename(LessThan) operator <;
%rename(LessThanEqual) operator <=;
%rename(GreaterThan) operator >;
%rename(GreaterThanEqual) operator >=;
%rename(And) operator &&;
%rename(Or) operator ||;
%rename(PlusPlusPrefix) operator++();
%rename(PlusPlusPostfix) operator++(int);
%rename(MinusMinusPrefix) operator--();
%rename(MinusMinusPostfix) operator--(int);

#endif
