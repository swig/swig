%module using_extend_flatten

// Issue #1581 - how to flatten all the methods in a base class into a derived class.
// Just ExtendDerived is exposed including the methods from the base class, exposed via a using declaration.

%extend ExtendDerived {
    using ExtendBase::one;
}
%ignore ExtendBase;

%inline %{
class ExtendBase
{
public:
    void one();
    virtual void two();
    virtual void three();
    virtual ~ExtendBase() {}
};

class ExtendDerived : public ExtendBase
{
public:
    void two();
    void three();
};
%}

%{
void ExtendBase::one() {}
void ExtendBase::two() {}
void ExtendBase::three() {}
void ExtendDerived::two() {}
void ExtendDerived::three() {}
%}
