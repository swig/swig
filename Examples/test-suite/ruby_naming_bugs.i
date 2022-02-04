%module ruby_naming_bugs

%inline %{
  // Prior to SWIG 4.1.0 the "Cool_" here was overzealously removed while
  // trying to remove a class name prefix.
  struct Cool {
    int somethingCool_Fast() { return 42; }
  };
%}
