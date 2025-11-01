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
};

%}


%inline %{
namespace BT {
struct MoveOnlyNode {
  MoveOnlyNode(const MoveOnlyNode& other) = delete;
#if !defined(SWIGGO)
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
#endif
};
struct MoveOnlyThing {
#if !defined(SWIGGO)
  using MOT = MoveOnlyThing&&;
  using MOT2 = MOT;
  MoveOnlyThing(const MoveOnlyThing& other) = delete;
  MoveOnlyThing(MOT2 other) = default;
  virtual ~MoveOnlyThing() = default;
#endif
};
}
%}
