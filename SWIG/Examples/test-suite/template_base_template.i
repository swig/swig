%module template_base_template

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) traits<double, double>; /* Ruby, wrong class name */

%warnfilter(SWIGWARN_PARSE_EXPLICIT_TEMPLATE);

%inline %{
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

%{
 template struct Function <double, double>;
 template struct Class <double, double>;
%}
 
%template(traits_dd) traits <double, double>;
%template(Function_dd) Function <double, double>;
%template(Class_dd) Class <double, double>;





