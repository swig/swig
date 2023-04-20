%module cpp11_rvalue_reference2

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) globalrrval;

// This testcase tests lots of different places that rvalue reference syntax can be used

%typemap(in) Something && "/*in Something && typemap*/"
%rename(OperatorRValue) Thingy::operator int&&;
%rename(memberFnRenamed) memberFn(short &&i);
%feature("compactdefaultargs") Thingy::compactDefaultArgs(const bool &&b = (const bool &&)PublicGlobalTrue, const UserDef &&u  = (const UserDef &&)PublicUserDef);
%feature("exception") Thingy::privateDefaultArgs(const bool &&b = (const bool &&)PrivateTrue);
%ignore Thingy::operator=;

%inline %{
#include <utility>
struct UserDef {
  int a;
};
static const bool PublicGlobalTrue = true;
static const UserDef PublicUserDef = UserDef();
struct Thingy {
  typedef int Integer;
  int valval;
  int &lvalref;
  int &&rvalref;
  Thingy(int v, int &&rvalv) : valval(v), lvalref(valval), rvalref(std::move(rvalv)) {}
  void refIn(long &i) {}
  void rvalueIn(long &&i) {}
  short && rvalueInOut(short &&i) { return std::move(i); }
  static short && staticRvalueInOut(short &&i) { return std::move(i); }
  // test both primitive and user defined rvalue reference default arguments and compactdefaultargs
  void compactDefaultArgs(const bool &&b = (const bool &&)PublicGlobalTrue, const UserDef &&u  = (const UserDef &&)PublicUserDef) {}
  void privateDefaultArgs(const bool &&b = (const bool &&)PrivateTrue) {}
  operator int &&() { return std::move(valval); }
  Thingy(const Thingy& rhs) : valval(rhs.valval), lvalref(rhs.lvalref), rvalref(std::move(rhs.rvalref)) {}
  Thingy& operator=(const Thingy& rhs) {
    valval = rhs.valval;
    lvalref = rhs.lvalref;
    rvalref = rhs.rvalref;
    return *this;
  }
private:
  static const bool PrivateTrue;
  Thingy();
};
const bool Thingy::PrivateTrue = true;

short && globalRvalueInOut(short &&i) { return std::move(i); }

int glob = 123;

Thingy &&globalrrval = Thingy(55, std::move(glob));

short && funk(short &&i) { return std::move(i); }
Thingy getit() { return Thingy(22, std::move(glob)); }

void rvalrefFunction1(int &&v = (int &&)5) {}
void rvalrefFunctionBYVAL(short (Thingy::*fptr)(short)) {}
void rvalrefFunctionPTR(short * (*fptr)(short *)) {}
void rvalrefFunctionLVALUE(short & (Thingy::*fptr)(short &)) {}
void rvalrefFunction2(short && (Thingy::*fptr)(short &&)) {}
void rvalrefFunction3(short && (*fptr)(short &&)) {}

template <typename T> struct RemoveReference {
     typedef T type;
};
 
template <typename T> struct RemoveReference<T&> {
     typedef T type;
};
 
template <typename T> struct RemoveReference<T&&> {
     typedef T type;
};
 
template <> struct RemoveReference<short &&> {
     typedef short type;
};
 
// like std::move
template <typename T> typename RemoveReference<T>::type&& Move(T&& t) {
    return static_cast<typename RemoveReference<T>::type&&>(t);
}
%}

%template(RemoveReferenceDouble) RemoveReference<double &&>;
%template(RemoveReferenceFloat) RemoveReference<float &&>;
%template(RemoveReferenceShort) RemoveReference<short &&>;
%template(MoveFloat) Move<float>;


