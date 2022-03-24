%module using_member_scopes

// Fully qualifying parameter types in a method declared after the using declaration caused
// a method being incorrectly added by the using declaration even though the declaration already existed

%inline %{
namespace OgreBites
{
    struct NativeWindowType {};
    class ApplicationContextBase {
    public:
        virtual ~ApplicationContextBase() {}
        virtual void setWindowGrab(NativeWindowType* win, bool grab = true) {}
        void setWindowGrab(bool grab = true) {}
    };
    class ApplicationContextSDL : public ApplicationContextBase {
    public:
        using ApplicationContextBase::setWindowGrab;
        void setWindowGrab(NativeWindowType* win, bool grab = true) {} // This should not be added again as it exists in base class
    };
/*
typedef not working yet
    class ApplicationContextSDL2 : public ApplicationContextBase {
    public:
        using ApplicationContextBase::setWindowGrab;
        typedef NativeWindowType* pNWT;
        void setWindowGrab(pNWT win, bool grab) {} // This should not be added again as it exists in base class
    };
*/
}
%}


%inline %{
// Test using declaration in various positions before and after overloaded methods
// Testing where the derived class overrides all the base class methods (and more)
namespace Bites
{
  struct Base
  {
    virtual ~Base() {}
    virtual void grab() {}
    virtual void grab(int i) {}
  };
  struct Derived1 : public Base
  {
    using Base::grab;
    virtual void grab() {}
    virtual void grab(int i) {}
  };
  struct Derived2 : public Base
  {
    using Base::grab;
    virtual void grab() {}
    virtual void grab(int i) {}
    virtual void grab(int i, double d) {}
  };
  struct Derived3 : public Base
  {
    virtual void grab() {}
    using Base::grab;
    virtual void grab(int i) {}
  };
  struct Derived4 : public Base
  {
    virtual void grab() {}
    using Base::grab;
    virtual void grab(int i) {}
    virtual void grab(int i, double d) {}
  };
  struct Derived5 : public Base
  {
    virtual void grab() {}
    virtual void grab(int i) {}
    using Base::grab;
  };
  struct Derived6 : public Base
  {
    virtual void grab() {}
    virtual void grab(int i) {}
    virtual void grab(int i, double d) {}
    using Base::grab;
  };
}
%}
