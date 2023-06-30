/* -----------------------------------------------------------------------------
 * doperators.swg
 *
 * Mapping of C++ operator overloading methods to D.
 * ----------------------------------------------------------------------------- */

%pragma(d) imdmodulecode=%{
mixin template SwigOperatorDefinitions() {
  public override bool opEquals(Object o) {
    if (auto rhs = cast(typeof(this))o) {
      if (swigCPtr == rhs.swigCPtr) return true;
      static if (is(typeof(swigOpEquals(rhs)))) {
        return swigOpEquals(rhs);
      } else {
        return false; 
      }
    }
    return super.opEquals(o);
  }
%}
// opEquals is emitted in pure C mode as well to define two proxy classes
// pointing to the same struct as equal.

#ifdef __cplusplus
%rename(swigOpPos) *::operator+();
%rename(swigOpPos) *::operator+() const;
%rename(swigOpNeg) *::operator-();
%rename(swigOpNeg) *::operator-() const;
%rename(swigOpCom) *::operator~();
%rename(swigOpCom) *::operator~() const;
%rename(swigOpInc) *::operator++();
%rename(swigOpDec) *::operator--();
%ignoreoperator(PLUSPLUS) *::operator++(int);
%ignoreoperator(MINUSMINUS) *::operator--(int);
// The postfix increment/decrement operators are ignored because they are
// rewritten to (auto t = e, ++e, t) in D2. The unary * operator (used for
// pointer dereferencing in C/C++) isn't mapped to opUnary("*") by default,
// despite this would be possible in D2 – the difference in member access
// semantics would only lead to confusion in most cases.

%rename(swigOpAdd) *::operator+;
%rename(swigOpSub) *::operator-;
%rename(swigOpMul) *::operator*;
%rename(swigOpDiv) *::operator/;
%rename(swigOpMod) *::operator%;
%rename(swigOpAnd) *::operator&;
%rename(swigOpOr) *::operator|;
%rename(swigOpXor) *::operator^;
%rename(swigOpShl) *::operator<<;
%rename(swigOpShr) *::operator>>;

%rename(swigOpAddAssign) *::operator+=;
%rename(swigOpSubAssign) *::operator-=;
%rename(swigOpMulAssign) *::operator*=;
%rename(swigOpDivAssign) *::operator/=;
%rename(swigOpModAssign) *::operator%=;
%rename(swigOpAndAssign) *::operator&=;
%rename(swigOpOrAssign) *::operator|=;
%rename(swigOpXorAssign) *::operator^=;
%rename(swigOpShlAssign) *::operator<<=;
%rename(swigOpShrAssign) *::operator>>=;

%rename(opIndex) *::operator[];
// opIndexAssign is not currently generated, it needs more extensive support
// mechanisms.

%rename(opCall) *::operator();

%rename(swigOpEquals) *::operator==;
%rename(swigOpLt) *::operator<;
%rename(swigOpLtEquals) *::operator<=;
%rename(swigOpGt) *::operator>;
%rename(swigOpGtEquals) *::operator>=;

// a != b is rewritten as !a.opEquals(b) in D.
%ignoreoperator(NOTEQUAL) operator!=;

// The logic operators are not overridable in D.
%ignoreoperator(LAND) operator&&;
%ignoreoperator(LOR) operator||;

// The C++ assignment operator does not translate well to D where the proxy
// classes have reference semantics.
%ignoreoperator(EQ) operator=;

%pragma(d) imdmodulecode=%{  
  public override int opCmp(Object o) {
    static if (__traits(compiles, swigOpLt(typeof(this).init) &&
        swigOpEquals(typeof(this).init))) {
      if (auto rhs = cast(typeof(this))o) {
        if (swigOpLt(rhs)) {
          return -1;
        } else if (swigOpEquals(rhs)) {
          return 0;
        } else {
          return 1;
        }
      }
    }
    return super.opCmp(o);
  }

  private template swigOpBinary(string operator, string name) {
    enum swigOpBinary = `public void opOpAssign(string op, T)(T rhs) if (op == "` ~ operator ~
      `" && __traits(compiles, swigOp` ~ name ~ `Assign(rhs))) { swigOp` ~ name ~ `Assign(rhs);}` ~
      `public auto opBinary(string op, T)(T rhs) if (op == "` ~ operator ~
      `" && __traits(compiles, swigOp` ~ name ~ `(rhs))) { return swigOp` ~ name ~ `(rhs);}`;
  }
  mixin(swigOpBinary!("+", "Add"));
  mixin(swigOpBinary!("-", "Sub"));
  mixin(swigOpBinary!("*", "Mul"));
  mixin(swigOpBinary!("/", "Div"));
  mixin(swigOpBinary!("%", "Mod"));
  mixin(swigOpBinary!("&", "And"));
  mixin(swigOpBinary!("|", "Or"));
  mixin(swigOpBinary!("^", "Xor"));
  mixin(swigOpBinary!("<<", "Shl"));
  mixin(swigOpBinary!(">>", "Shr"));
  
  private template swigOpUnary(string operator, string name) {
    enum swigOpUnary = `public auto opUnary(string op)() if (op == "` ~ operator ~
      `" && __traits(compiles, swigOp` ~ name ~ `())) { return swigOp` ~ name ~ `();}`;   
  }
  mixin(swigOpUnary!("+", "Pos"));
  mixin(swigOpUnary!("-", "Neg"));
  mixin(swigOpUnary!("~", "Com"));
  mixin(swigOpUnary!("++", "Inc"));
  mixin(swigOpUnary!("--", "Dec"));
%}
#endif

%pragma(d) imdmodulecode=%{
}
%}
