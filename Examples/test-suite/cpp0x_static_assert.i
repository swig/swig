/* This test case checks whether swig correctly parses and ignores the
   keywords "static_assert()" inside the class or struct.
*/
%module static_assert

%inline %{
template <typename T>
struct Check1 {
        static_assert(sizeof(int) <= sizeof(T), "not big enough");
};

template <typename T>
class Check2 {
        static_assert(sizeof(int) <= sizeof(T), "not big enough");
};
%}

