%module(directors="1") director_using_member_scopes

// Similar to using_member_scopes but for directors

#if !defined(SWIGGO) // TODO: fix Go crash

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
        virtual int setWindowGrab(NativeWindowType* win, bool grab = true) { return 0; }
        int setWindowGrab(bool grab = true) { return 5; }

        static int call_setWindowGrab(ApplicationContextBase* ptr, NativeWindowType* win, bool grab) { return ptr->setWindowGrab(win, grab); }
    };
    class ApplicationContextSDL : public ApplicationContextBase {
    public:
        using ApplicationContextBase::setWindowGrab;
        int setWindowGrab(NativeWindowType* win, bool grab = true) { return 10; } // This should not be added again as it exists in base class

        static int call_setWindowGrab(ApplicationContextSDL* ptr, NativeWindowType* win, bool grab) { return ptr->setWindowGrab(win, grab); }
    };

    class ACB {
    public:
        virtual ~ACB() {}
        virtual int setWindowGrab(NativeWindowType* win, bool grab = true) { return 0; }
        virtual int setWindowGrab(const char *s, int val) { return 1; } // Additional method compared to ApplicationContextBase
        int setWindowGrab(bool grab = true) { return 5; }

        static int call_setWindowGrab(ACB* ptr, NativeWindowType* win, bool grab) { return ptr->setWindowGrab(win, grab); }
        static int call_setWindowGrab(ACB* ptr, const char *s, int val) { return ptr->setWindowGrab(s, val); }
    };
    class ACSDL : public ACB {
    public:
        using ACB::setWindowGrab; // This introduces two methods, not one method like ApplicationContextSDL
        int setWindowGrab(NativeWindowType* win, bool grab = true) { return 10; } // This should not be added again as it exists in base class

        static int call_setWindowGrab(ACSDL* ptr, NativeWindowType* win, bool grab) { return ptr->setWindowGrab(win, grab); }
        static int call_setWindowGrab(ACSDL* ptr, const char *s, int val) { return ptr->setWindowGrab(s, val); }
    };
}
%}

#endif
