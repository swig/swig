%module cpp11_shared_ptr_template_upcast

%{
#include <memory>
#include <string>
%}

#if defined(SWIGC) || defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGPYTHON) || defined(SWIGD) || defined(SWIGOCTAVE) || defined(SWIGRUBY) || defined(SWIGR) || defined(SWIGLUA)
#define SHARED_PTR_WRAPPERS_IMPLEMENTED
#endif

#if defined(SHARED_PTR_WRAPPERS_IMPLEMENTED)
%include <std_shared_ptr.i>
#endif

%include <std_string.i>

%{
class Base {
public:
    Base() : value(0) {}
    Base(int v) : value(v) {}
    virtual ~Base() {}
    
    virtual int GetResult() = 0;
    
    int value;
};

class Derived : public Base {
public:
    Derived() : Base() {}
    Derived(int v) : Base(v) {}
    virtual ~Derived() {}
    
    int GetResult() { return value*2; }
};

template <class T> class Printable : virtual public T {
public:
    Printable(int param) : T(param) {}
    ~Printable() {}

    std::string GetFormatted() { return std::string("The formatted result is: ").append(std::to_string(this->GetResult())); }
};

std::shared_ptr<Printable<Derived> > MakePrintableDerived(int param) {
    return std::make_shared<Printable<Derived> >(param);
}

%}

#if defined(SHARED_PTR_WRAPPERS_IMPLEMENTED)
%shared_ptr(Base);
%shared_ptr(Derived);
%shared_ptr(Printable<Derived>)
#endif

class Base {
public:
    Base();
    Base(int v);
    virtual ~Base();
    
    virtual int GetResult() = 0;
    
    int value;
};

class Derived : public Base {
public:
    Derived();
    Derived(int v);
    virtual ~Derived();
    
    int GetResult();
};

/*
    Virtual inheritance is contrived for this case, but exposes whether SWIGSmartPtrUpcast generated a correctly typed shared pointer of the upcasted class type -
    if the pointer type is incorrect, this will result in a segmentation fault (on Windows, this could manifest as undefined behavior) when trying to access members 
    inherited from T through a shared_ptr<Printable<T> >.
*/
template <class T> class Printable : virtual public T {
public:
    Printable(int param);
    ~Printable();

    std::string GetFormatted();
};

std::shared_ptr<Printable<Derived> > MakePrintableDerived(int param);


%template(PrintableDerived) Printable<Derived>;


