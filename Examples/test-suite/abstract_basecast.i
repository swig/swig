%module abstract_basecast

%inline %{
class BaseClass {
public:
    virtual ~BaseClass() { }

    virtual void g() = 0;
};

class DerivedClass : public BaseClass {
public:

    virtual void g() { }

    BaseClass& f() {
        return *this;
    }
};
%}
