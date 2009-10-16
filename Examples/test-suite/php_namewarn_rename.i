%module php_namewarn_rename

#ifdef SWIGPHP
%warnfilter(SWIGWARN_PARSE_KEYWORD) Empty();
// FIXME: this doesn't work for me:
%warnfilter(SWIGWARN_PARSE_KEYWORD) stdClass;
%warnfilter(SWIGWARN_PARSE_KEYWORD) Hello::empty();
#endif

%inline %{

  void Empty() {}

  class stdClass
  {
  };

  struct Hello
  {
    void empty() {}
  };

%}
