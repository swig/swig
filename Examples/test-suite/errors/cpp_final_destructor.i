%module(directors="1") cpp11_final_destructor;
// Check SWIG will not wrap these classes as directors where the destructors are final
%director BaseFinal;
%director BaseNoexceptFinal;

%inline %{
struct BaseFinal {
  virtual ~BaseFinal() final {}
  virtual void basemeth() {}
};

struct BaseNoexceptFinal {
  // Regression test for bug fixed in 4.3.0 - SWIG was ignoring final after noexcept.
  virtual ~BaseNoexceptFinal() noexcept final {}
  virtual void basemeth() {}
};

%}
