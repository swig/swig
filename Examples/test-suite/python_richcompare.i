/* Test the tp_richcompare functions generated with the -builtin option */

%module python_richcompare

%inline {

class BaseClass {
public:
    BaseClass (int i_) : i(i_) {}
    ~BaseClass () {}

    int getValue () const
    { return i; }
    
    bool operator< (const BaseClass& x) const
    { return this->i < x.i; }

    bool operator> (const BaseClass& x) const
    { return this->i > x.i; }

    bool operator<= (const BaseClass& x) const
    { return this->i <= x.i; }

    bool operator>= (const BaseClass& x) const
    { return this->i >= x.i; }

    bool operator== (const BaseClass& x) const
    { return this->i == x.i; }

    bool operator!= (const BaseClass& x) const
    { return this->i != x.i; }

    int i;
};

class SubClassA : public BaseClass {
public:
    SubClassA (int i_) : BaseClass(i_) {}
    ~SubClassA () {}

    bool operator== (const SubClassA& x) const
    { return true; }

    bool operator== (const BaseClass& x) const
    { return false; }
};

class SubClassB : public BaseClass {
public:
    SubClassB (int i_) : BaseClass(i_) {}
    ~SubClassB () {}

    bool operator== (const SubClassB& x) const
    { return true; }

    bool operator== (const SubClassA& x) const
    { return false; }
};
}

// Test custom exceptions can still be thrown in operators which use %pythonmaybecall
%{
struct ZeroValueProblem {
    ZeroValueProblem() {}
};
%}

%exception ExceptionThrower::operator< {
    try
    {
        $action
    }
    catch(const ZeroValueProblem&)
    {
        PyErr_SetString(PyExc_ValueError, "Zero not liked in operator<");
        SWIG_fail;
    }
}

%inline {
class ExceptionThrower {
    int i;
public:
    ExceptionThrower (int i_) : i(i_) {}
    bool operator< (const ExceptionThrower& rhs) const {
        if (rhs.i == 0 || i == 0)
            throw ZeroValueProblem();
        return this->i < rhs.i;
    }
};
}

%exception SubClassCThrower::operator== {
    try
    {
        $action
    }
    catch(const ZeroValueProblem&)
    {
        PyErr_SetString(PyExc_ValueError, "Zero not liked in operator==");
        SWIG_fail;
    }
}

// Overloaded operators and custom exceptions
%inline {
class SubClassCThrower : public BaseClass {
public:
    SubClassCThrower (int i_) : BaseClass(i_) {}
    ~SubClassCThrower () {}

    bool operator== (const SubClassCThrower& rhs) const
    {
        if (rhs.i == 0 || i == 0)
            throw ZeroValueProblem();
        return rhs.i == i;
    }

    bool operator== (const SubClassA& rhs) const
    { return rhs.i == i; }
};
}
