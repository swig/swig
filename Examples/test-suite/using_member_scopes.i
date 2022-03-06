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
        void setWindowGrab(NativeWindowType* win, bool grab) {} // This should not be added again as it exists in base class
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
