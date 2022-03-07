%module(directors="1") director_using_member_scopes

// Similar to using_member_scopes but for directors

#if !defined(SWIGGO)

%feature("director");
// Python,Java,C# no diffs in generated code when adding in nodirector. Go not happy even without %nodirector.
// Fully qualifying parameter types in a method declared after the using declaration caused
// a method being incorrectly added by the using declaration even though the declaration already existed

// Github issue #1441 - segfault in Go and C#

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
}
%}

#endif
