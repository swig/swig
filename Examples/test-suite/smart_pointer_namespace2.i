
%module smart_pointer_namespace2
%{
namespace one
{
    template <typename T>
    class Ptr
    {
        T* p;
    public:
        Ptr(T *tp) : p(tp) {}
        ~Ptr() { };
        T* operator->() { return p; }
    };
}
namespace one
{
    class Obj1
    {
    public:
        Obj1() {}
        void donothing() {}
    };
    typedef one::Ptr<Obj1> Obj1_ptr;
}

namespace two
{
    class Obj2
    {
    public:
        Obj2() {}
        void donothing() {}
    };
    typedef one::Ptr<Obj2> Obj2_ptr;
}
%}

namespace one
{
    template <typename T>
    class Ptr
    {
        T* p;
    public:
        Ptr(T *tp) : p(tp) {}
        ~Ptr() { };
        T* operator->() { return p; }
    };
}

namespace one
{
    class Obj1
    {
    public:
        Obj1() {}
        void donothing() {}
    };

    typedef one::Ptr<Obj1> Obj1_ptr;
    %template(Obj1_ptr) one::Ptr<Obj1>;
}

namespace two
{
    class Obj2
    {
    public:
        Obj2() {}
        void donothing() {}
    };

    typedef one::Ptr<Obj2> Obj2_ptr;
}

using two::Obj2;
%template(Obj2_ptr) one::Ptr<Obj2>;

