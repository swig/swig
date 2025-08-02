%module doxygen_overloads

%inline %{

void overloadWithNoDoc(int) { }
void overloadWithNoDoc(double) { }

/// Doc for first overload.
void overloadWithFirstDoc(int) { }
void overloadWithFirstDoc(double) { }

void overloadWithSecondDoc(int) { }
/// Doc for second overload.
void overloadWithSecondDoc(double) { }

/// Doc for both overloads, first.
void overloadWithBothDocs(int) { }
/// Doc for both overloads, second.
void overloadWithBothDocs(double) { }

/// Doc for some overloads, first.
void overloadWithSomeDocs(int) { }
void overloadWithSomeDocs(double) { }
/// Doc for some overloads, third.
void overloadWithSomeDocs(char) { }

/// Doc for some other overloads, first.
void overloadWithSomeOtherDocs(int) { }
/// Doc for some other overloads, second.
void overloadWithSomeOtherDocs(double) { }
void overloadWithSomeOtherDocs(char) { }


// Also test different kinds of member functions.

struct S {
    /// Doc for first static overload.
    static void staticOverloadWithFirstDoc(int) { }
    static void staticOverloadWithFirstDoc(double) { }

    /// Doc for first member overload.
    void memberOverloadWithFirstDoc(int) { }
    void memberOverloadWithFirstDoc(double) { }
};

// Class ctors are handled differently from the other functions, so check them too.

struct ClassWithNoDoc {
    ClassWithNoDoc(int) { }
    ClassWithNoDoc(double) { }
};

struct ClassWithFirstDoc {
    /// Doc for first ctor.
    ClassWithFirstDoc(int) { }
    ClassWithFirstDoc(double) { }
};

struct ClassWithSecondDoc {
    ClassWithSecondDoc(int) { }
    /// Doc for second ctor.
    ClassWithSecondDoc(double) { }
};

struct ClassWithBothDocs {
    /// Doc for both ctors, first.
    ClassWithBothDocs(int) { }
    /// Doc for both ctors, second.
    ClassWithBothDocs(double) { }
};

struct ClassWithSomeDocs {
    /// Doc for some ctors, first.
    ClassWithSomeDocs(int) { }
    ClassWithSomeDocs(double) { }
    /// Doc for some ctors, third.
    ClassWithSomeDocs(char) { }
};

struct ClassWithSomeOtherDocs {
    /// Doc for some other ctors, first.
    ClassWithSomeOtherDocs(int) { }
    /// Doc for some other ctors, second.
    ClassWithSomeOtherDocs(double) { }
    ClassWithSomeOtherDocs(char) { }
};


#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif

%}
