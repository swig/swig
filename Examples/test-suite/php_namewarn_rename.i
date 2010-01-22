%module php_namewarn_rename

#ifdef SWIGPHP
%warnfilter(SWIGWARN_PARSE_KEYWORD) Empty();
%warnfilter(SWIGWARN_PARSE_KEYWORD) stdClass;
%warnfilter(SWIGWARN_PARSE_KEYWORD) directory;
%warnfilter(SWIGWARN_PARSE_KEYWORD) Hello::empty();
#endif

%inline %{

  int Exception() { return 13; }

  void Empty() {}

  class stdClass
  {
  };

  class directory
  {
  };

  struct Hello
  {
    void empty() {}
  };

%}
