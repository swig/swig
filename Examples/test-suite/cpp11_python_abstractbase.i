%module cpp11_python_abstractbase

// pyabc.i registers the C++98 containers with the abstract base classes and defines the
// %pythonabc macro. The unordered containers are C++11, so they are registered here.
%include <pyabc.i>

%pythonabc(std::unordered_map, "collections.abc.MutableMapping");
%pythonabc(std::unordered_multimap, "collections.abc.MutableMapping");
%pythonabc(std::unordered_set, "collections.abc.MutableSet");
%pythonabc(std::unordered_multiset, "collections.abc.MutableSet");

%include <std_unordered_map.i>
%include <std_unordered_multimap.i>
%include <std_unordered_set.i>
%include <std_unordered_multiset.i>

namespace std
{
  %template(UnorderedMapii) unordered_map<int, int>;
  %template(UnorderedMultimapii) unordered_multimap<int, int>;
  %template(UnorderedIntSet) unordered_set<int>;
  %template(UnorderedIntMultiset) unordered_multiset<int>;
}

%inline %{
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}
