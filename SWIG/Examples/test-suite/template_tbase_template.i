%module template_tbase_template

%warnfilter(801) traits<Double, Double>;	/* Ruby, wrong class name */

#pragma SWIG nowarn=320

%inline %{
  typedef double Double;

 
  template <class ArgType, class ResType>
  struct Function
  {
	char *test() { return (char *) "test"; }
  };

  template <class ArgType, class ResType>
  struct traits
  {
    typedef ArgType arg_type;
    typedef ResType res_type;
    typedef Function<ArgType, double> base;	
  };

  // Egad!
  template <class AF, class AG>
  struct Class
    : Function<typename traits<AF, AG>::arg_type,
                                typename traits<AF, AG>::res_type>
  {
  };
 
  template <class AF, class RF>
  typename traits<AF, RF>::base
  make_Class()
  {
    return Class<AF, RF>();
  }

%}
%{
  template class Function <Double, Double>;
  template class Class <Double, Double>; 
%}
 
%template(traits_dd) traits <Double, Double>;
%template(Function_dd) Function <Double, Double>;
%template(Class_dd) Class <Double, Double>;
%template(make_Class_dd) make_Class<Double,Double>;
