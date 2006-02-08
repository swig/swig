%module ignore_template_constructor

%include <std_vector.i>

// Check common problem for vector wrappers - the default constructor is not available, so it must be ignored
//%feature("ignore") std::vector<Flow>::vector(size_type); // works
%ignore std::vector<Flow>::vector(size_type); // does not work

%inline %{
class Flow {
 Flow() {}
public:
 Flow(double d) {}
};
%}

%template(VectFlow) std::vector<Flow>;
