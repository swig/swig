%module ignore_template_constructor
%include std_vector.i

#if defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGPYTHON) || defined(SWIGPERL)
#define SWIG_GOOD_VECTOR
%ignore std::vector<Flow>::vector(size_type);
%ignore std::vector<Flow>::resize(size_type);
#endif

#if defined(SWIGTCL) || defined(SWIGPERL)
#define SWIG_GOOD_VECTOR
/* here, for languages with bad declaration */
%ignore std::vector<Flow>::vector(unsigned int);
%ignore std::vector<Flow>::resize(unsigned int);
#endif

#if defined(SWIG_GOOD_VECTOR)
%inline %{
class Flow {
  Flow() {}
public:
  Flow(double d) {}
};
%}

#else
/* here, for languages with bad typemaps */

%inline %{
class Flow {
public:
  Flow() {}
  Flow(double d) {}
};
%}

#endif

%template(VectFlow) std::vector<Flow>;
