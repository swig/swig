%module nspacemove_stl

#if defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGD) || defined(SWIGLUA) || defined(SWIGJAVASCRIPT)

#if defined(SWIGJAVA)
SWIG_JAVABODY_PROXY(public, public, SWIGTYPE)
#endif

// %nspacemove needed before %include std_vector.i, std_map.i etc so that this nspace targetting the template is attached to the template node
%nspacemove(CPlusPlus::Maps) std::map;

%include <stl.i>

// %nspacemove needed at least before instantiation of the templates
%nspacemove(CPlusPlus::Standard::Ints) std::vector<int>;
%nspacemove(CPlusPlus::Standard::Strings) std::vector<std::string>;

%template(VectorInt) std::vector<int>;
%template(VectorString) std::vector<std::string>;

%template(MapIntInt) std::map<int, int>;
%template(MapIntString) std::map<int, std::string>;

%inline %{
void test_vector_int(std::vector<int> a) {}
void test_vector_string(std::vector<std::string> a) {}
void test_map_int(std::map<int, int> a) {}
void test_map_string(std::map<int, std::string> a) {}
%}

#endif
