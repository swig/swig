%module template_tbase_template
%inline %{
  typedef double Double;

  template <class ArgType, class ResType>
  struct traits
  {
    typedef ArgType arg_type;
    typedef ResType res_type;
  };
 
  template <class ArgType, class ResType>
  struct Function
  {
  };

  // Egad!
  template <class AF, class AG>
  struct Class
    : Function<typename traits<AF, AG>::arg_type,
                                typename traits<AF, AG>::res_type>
  {
  };
 
%}
 
%template(traits_dd) traits <Double, Double>;
%template(Function_dd) Function <Double, Double>;
%template(Class_dd) Class <Double, Double>;





