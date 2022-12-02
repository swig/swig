%module(directors="1") director_template

%{
#include <vector>
%}

%include <std_vector.i>

%feature("director") HandleBytes;

%inline %{
  template <typename X, typename Y> class TwoTemplateParms {};
%}

%template(TT_int_double) TwoTemplateParms<int, double>;

%inline %{
  class HandleBytes {
  public:
    virtual void handle(const std::vector<unsigned char> data) = 0; // Note: not instantiated with %template
    virtual void handle2(TwoTemplateParms<int, double> data) = 0;
    virtual ~HandleBytes() {}
  };

  void bytes_wrapper(const std::vector<unsigned char> data, HandleBytes *handler) {
    handler->handle(data);
  }
%}
