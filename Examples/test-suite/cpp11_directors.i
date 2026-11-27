%module(directors="1") cpp11_directors
%feature("director");

%inline %{

class Foo {
  public:
    virtual ~Foo() noexcept {}
    virtual int ping() noexcept = 0;
    virtual int pong() noexcept = 0;
    virtual int pang() const& noexcept = 0;
    virtual int peng() & noexcept = 0;
    virtual int pung() & = 0;
    virtual auto pyng() const noexcept -> int = 0;
};

// The exception specification of a function returning a function pointer goes inside the parentheses
int funcPtrAddOne(int i) { return i + 1; }
class FuncPtrReturner {
  public:
    virtual ~FuncPtrReturner() noexcept {}
    virtual int (*ptr1() noexcept)(int) { return funcPtrAddOne; }
    virtual int (*ptr2() const noexcept)(int) { return funcPtrAddOne; }
    virtual int (*ptr3() const & noexcept)(int) { return funcPtrAddOne; }
};
int callFuncPtrs(FuncPtrReturner &r, int i) { return r.ptr1()(i) + r.ptr2()(i) + r.ptr3()(i); }

%}

%{
// A dummy director exception class for the target languages without directors
#ifndef SWIG_DIRECTORS
namespace Swig {
  class DirectorException {};
}
#endif
%}

%catches(Swig::DirectorException) NoExceptFalse::callPing;

#ifdef SWIGPYTHON
// The Python exception raised by the override is still set
%typemap(throws) Swig::DirectorException %{
  (void)$1;
  SWIG_fail;
%}
#endif

%inline %{
// The director method of a noexcept(false) method is not noexcept, so an exception from an override reaches the caller
class NoExceptFalse {
  public:
    virtual ~NoExceptFalse() {}
    virtual int ping() noexcept(false) { return 1; }
    static int callPing(NoExceptFalse &n) { return n.ping(); }
};
%}


%inline %{
namespace BT {
struct MoveOnlyNode {
  MoveOnlyNode(const MoveOnlyNode& other) = delete;
  MoveOnlyNode(MoveOnlyNode&& other) = default;
  MoveOnlyNode(int a, double d) {}
  MoveOnlyNode() = default;
  virtual ~MoveOnlyNode() = default;
  virtual void rvalues_int(int &&) {}
  virtual void rvalues_mo(MoveOnlyNode &&) {}
  virtual void rvalues_mo_overload(MoveOnlyNode &&) {}
  virtual void rvalues_mo_overload(int, double, MoveOnlyNode &&) {}

  using DoubleRVR = double&&;
  using MoveOnlyNodeRVR = MoveOnlyNode&&;
  virtual void rvalues_using(DoubleRVR, MoveOnlyNodeRVR p2) {}
  using DoubleRVR2 = DoubleRVR;
  using MoveOnlyNodeRVR2 = MoveOnlyNodeRVR;
  virtual void rvalues_using2(DoubleRVR2 p1, MoveOnlyNodeRVR2) {}
};
struct MoveOnlyThing {
  using MOT = MoveOnlyThing&&;
  using MOT2 = MOT;
  MoveOnlyThing(const MoveOnlyThing& other) = delete;
  MoveOnlyThing(MOT2 other) = default;
  virtual ~MoveOnlyThing() = default;
};
}
%}
