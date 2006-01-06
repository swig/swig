/* ------------------------------------------------------------
 * Overloaded operator support
 * ------------------------------------------------------------ */

#ifdef __cplusplus

// These are auto-supported by the Perl-module
%rename(__plusplus__) *::operator++;
%rename(__minmin__)   *::operator--;
%rename(__add__)      *::operator+;
%rename(__sub__)      *::operator-;
%rename(__neg__)      *::operator-();
%rename(__neg__)      *::operator-() const;
%rename(__mul__)      *::operator*;
%rename(__div__)      *::operator/;
%rename(__eq__)       *::operator==;
%rename(__ne__)       *::operator!=;
%rename(__mod__)      *::operator%;
%rename(__gt__)       *::operator>;
%rename(__lt__)       *::operator<;
%rename(__and__)      *::operator and;
%rename(__or__)       *::operator or;

// These are renamed, but no 'use overload...' is added
%rename(__lshift__)   *::operator<<;
%rename(__rshift__)   *::operator>>;
%rename(__and__)      *::operator&;
%rename(__or__)       *::operator|;
%rename(__xor__)      *::operator^;
%rename(__invert__)   *::operator~;
%rename(__le__)       *::operator<=;
%rename(__ge__)       *::operator>=;
%rename(__call__)     *::operator();

/* Ignored operators */
%ignorewarn("390:operator+  ignored")  operator+();
%ignorewarn("390:operator+  ignored")  operator+() const;
%ignorewarn("362:operator=  ignored")  operator=;
%ignorewarn("365:operator+= ignored")  operator+=;
%ignorewarn("366:operator-= ignored")  operator-=;
%ignorewarn("367:operator*= ignored")  operator*=;
%ignorewarn("368:operator/= ignored")  operator/=;
%ignorewarn("369:operator%= ignored")  operator%=;
%ignorewarn("375:operator<<= ignored") operator<<=;
%ignorewarn("376:operator>>= ignored") operator>>=;
%ignorewarn("371:operator&= ignored")  operator&=;
%ignorewarn("372:operator|= ignored")  operator|=;
%ignorewarn("370:operator^= ignored")  operator^=;
%ignorewarn("381:operator&& ignored")  operator&&;
%ignorewarn("382:operator|| ignored")  operator||;
%ignorewarn("387:operator-> ignored")  operator->;
%ignorewarn("386:operator->* ignored") operator->*;
%ignorewarn("389:operator[] ignored (consider using %extend)") operator[];

#endif /* __cplusplus */
