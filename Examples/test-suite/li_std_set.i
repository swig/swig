/*
 * a test of set containers.
 * Languages should define swig::LANGUAGE_OBJ to be
 * an entity of their native pointer type which can be
 * included in a STL container.
 *
 * For example:
 *   swig::LANGUAGE_OBJ  is  GC_VALUE in Ruby
 *   swig::LANGUAGE_OBJ  is  SwigPtr_PyObject in python
 */

%module li_std_set

%include <std_string.i>
%include <std_set.i>
%include <std_vector.i>

// Use language macros since Java and C# don't have multiset support (yet)
// and uses different naming conventions.
#if defined(SWIGRUBY) || defined(SWIGPYTHON)
    %include <std_multiset.i>
    %template(set_int) std::multiset<int>;
    %template(v_int) std::vector<int>;
    %template(set_string) std::set<std::string>;
#elif defined(SWIGJAVA) || defined(SWIGCSHARP)
    // This operator is only defined because it's needed to store objects of
    // type Foo in std::set in C++, we don't need to wrap it.
    %ignore operator<;
    %inline %{
        struct Foo
        {
            explicit Foo(int n) : n(n) {}

            int n;

            friend bool operator<(Foo foo1, Foo foo2)
            {
                return foo1.n < foo2.n;
            }
        };
    %}

    %template(IntSet) std::set<int>;
    %template(StringSet) std::set<std::string>;
    %template(FooSet) std::set<Foo>;
#endif

#if defined(SWIGRUBY)
%template(LanguageSet) std::set<swig::LANGUAGE_OBJ>;
#endif

#if defined(SWIGPYTHON)
%template(pyset) std::set<swig::SwigPtr_PyObject>;
#endif
