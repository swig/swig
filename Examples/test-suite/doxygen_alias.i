%module doxygen_alias

#ifdef SWIGJAVA
%feature("doxygen:alias:nullptr") "null"
#elif defined(SWIGPYTHON)
%feature("doxygen:alias:nullptr") "None"
#else
%feature("doxygen:alias:nullptr") "NULL"
#endif

%inline %{

class Something {};

/**
    A function returning something.

    @returns A new object which may be @nullptr.
 */
Something* make_something() { return 0; }

%}
