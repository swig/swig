/* -----------------------------------------------------------------------------
 * python.swg
 *
 * Python configuration module.
 * ----------------------------------------------------------------------------- */

%insert(runtime) "common.swg";
%insert(runtime) "pyrun.swg";


/* Overloaded operator support */

#ifdef __cplusplus
%rename(__add__)      *::operator+;
%rename(__pos__)      *::operator+();
%rename(__sub__)      *::operator-;
%rename(__neg__)      *::operator-();
%rename(__mul__)      *::operator*;
%rename(__div__)      *::operator/;
%rename(__mod__)      *::operator%;
%rename(__lshift__)   *::operator<<;
%rename(__rshift__)   *::operator>>;
%rename(__and__)      *::operator&;
%rename(__or__)       *::operator|;
%rename(__xor__)      *::operator^;
%rename(__invert__)   *::operator~;
%rename(__iadd__)     *::operator+=;
%rename(__isub__)     *::operator-=;
%rename(__imul__)     *::operator*=;
%rename(__idiv__)     *::operator/=;
%rename(__imod__)     *::operator%=;
%rename(__ilshift__)  *::operator<<=;
%rename(__irshift__)  *::operator>>=;
%rename(__iand__)     *::operator&=;
%rename(__ior__)      *::operator|=;
%rename(__ixor__)     *::operator^=;
%rename(__lt__)       *::operator<;
%rename(__le__)       *::operator<=;
%rename(__gt__)       *::operator>;
%rename(__ge__)       *::operator>=;
%rename(__eq__)       *::operator==;
%rename(__ne__)       *::operator!=;

/* Special cases */
%rename(__call__)     *::operator();

/* Ignored operators */
%ignorewarn("operator= ignored") operator=;
%ignorewarn("operator++ ignored") operator++;
%ignorewarn("operator-- ignored") operator--;
%ignorewarn("operator&& ignored") operator&&;
%ignorewarn("operator|| ignored") operator&&;
%ignorewarn("operator-> ignored") operator->;
%ignorewarn("operator->* ignored") operator->*;
%ignorewarn("operator[] ignored (consider using %addmethods)") operator[];

#endif

/* Warnings for certain Python keywords */
#define PYKW(x) %namewarn(#x " is a python keyword")  #x;

PYKW(and)
PYKW(assert)
PYKW(break)
PYKW(class)
PYKW(continue)
PYKW(def)
PYKW(del)
PYKW(elif)
PYKW(else)
PYKW(except)
PYKW(exec)
PYKW(finally)
PYKW(for)
PYKW(from)
PYKW(global)
PYKW(if)
PYKW(import)
PYKW(in)
PYKW(is)
PYKW(lambda)
PYKW(not)
PYKW(or)
PYKW(pass)
PYKW(print)
PYKW(raise)
PYKW(return)
PYKW(try)
PYKW(while)







