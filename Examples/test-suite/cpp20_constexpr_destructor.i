%module cpp20_constexpr_destructor

// Test constexpr destructors introduced in C++20

%inline %{
class DtorA {
public:
    constexpr ~DtorA() {}
};

class DtorB {
public:
    constexpr ~DtorB();
};

constexpr DtorB::~DtorB() {}

class DtorC {
public:
    virtual constexpr ~DtorC() {}
};

class DtorD {
public:
    constexpr virtual ~DtorD() {}
};

class DtorE {
public:
    inline virtual constexpr ~DtorE() {}
};

class DtorF {
public:
    virtual constexpr ~DtorF() = 0;
};

class DtorG {
public:
    virtual constexpr ~DtorG() = default;
};

template<typename T>
struct DtorTemplate {
    virtual constexpr ~DtorTemplate();
};

template<typename T>
constexpr DtorTemplate<T>::~DtorTemplate() {}
%}
