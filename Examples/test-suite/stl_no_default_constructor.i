%module stl_no_default_constructor

%include <stl.i>

%inline %{
struct NoDefaultCtor {
  int value;
  NoDefaultCtor(int i) : value(i) {}
};
%}

#if defined(SWIGCSHARP) || defined(SWIGJAVA) || defined(SWIGD)
%template(VectorNoDefaultCtor) std::vector<NoDefaultCtor>;
#endif

#if defined(SWIGJAVA) || defined(SWIGJAVA)
%include <std_list.i>
%template(ListNoDefaultCtor) std::list<NoDefaultCtor>;
#endif
