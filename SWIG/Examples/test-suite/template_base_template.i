%module template_base_template

%warnfilter(801) traits<double, double>; /* Ruby, wrong class name */

%warnfilter(320);

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
 template class Function <double, double>;
 template class Class <double, double>;
%}
 
%template(traits_dd) traits <double, double>;
%template(Function_dd) Function <double, double>;
%template(Class_dd) Class <double, double>;





