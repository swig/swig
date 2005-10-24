/* ------------------------------------------------------------
 * Overloaded operator support
 * ------------------------------------------------------------ */

#ifdef __cplusplus

%rename(__add__)      *::operator+;
%rename(__pos__)      *::operator+();
%rename(__pos__)      *::operator+() const;
%rename(__sub__)      *::operator-;
%rename(__neg__)      *::operator-();
%rename(__neg__)      *::operator-() const;
%rename(__mul__)      *::operator*;
%rename(__div__)      *::operator/;
%rename(__mod__)      *::operator%;
%rename(__lshift__)   *::operator<<;
%rename(__rshift__)   *::operator>>;
%rename(__and__)      *::operator&;
%rename(__or__)       *::operator|;
%rename(__xor__)      *::operator^;
%rename(__invert__)   *::operator~;
%rename(__lt__)       *::operator<;
%rename(__le__)       *::operator<=;
%rename(__gt__)       *::operator>;
%rename(__ge__)       *::operator>=;
%rename(__eq__)       *::operator==;

/* Special cases */
%rename(__call__)     *::operator();

/* Ignored operators */
%ignorewarn("378:operator!= ignored")  operator!=;
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
%ignorewarn("362:operator= ignored")   operator=;
%ignorewarn("383:operator++ ignored")  operator++;
%ignorewarn("384:operator-- ignored")  operator--;
%ignorewarn("381:operator&& ignored")  operator&&;
%ignorewarn("382:operator|| ignored")  operator||;
// %ignorewarn("387:operator-> ignored")  operator->;
%ignorewarn("386:operator->* ignored") operator->*;
%ignorewarn("389:operator[] ignored (consider using %extend)") operator[];

#endif /* __cplusplus */
