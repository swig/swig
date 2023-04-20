%module xxx

%rename(UseMe) use_me(int i);
%rename(UseMeToo) Derived::use_me_too;

class Base
{
public:
    void use_me(Base *);
    void use_me(int i);
    bool use_me_too(double d) const;
    bool use_me_too(bool b) const;
};

class Derived : public Base
{
public:
    using Base::use_me;
    using Base::use_me_too;
    using Base::does_not_exist;
};

