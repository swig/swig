%module ignore_template_constructor
%include std_vector.i

%ignore std::vector<Flow>::vector(size_type);
%ignore std::vector<Flow>::resize(size_type);


%inline %{


class Flow {
  Flow() {}
public:
  Flow(double d) {}
};
%}

%template(VectFlow) std::vector<Flow>;
