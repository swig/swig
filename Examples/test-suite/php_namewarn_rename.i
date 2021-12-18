%module php_namewarn_rename

#ifdef SWIGPHP
%warnfilter(SWIGWARN_PARSE_KEYWORD) Empty();
%warnfilter(SWIGWARN_PARSE_KEYWORD) stdClass;
%warnfilter(SWIGWARN_PARSE_KEYWORD) directory;
%warnfilter(SWIGWARN_PARSE_KEYWORD) Hello::empty();
%warnfilter(SWIGWARN_PARSE_KEYWORD) null;
%warnfilter(SWIGWARN_PARSE_KEYWORD) True;
%warnfilter(SWIGWARN_PARSE_KEYWORD) FALSE;
%warnfilter(SWIGWARN_PARSE_KEYWORD) ns::readonly;
#endif

%ignore prev::operator++;
%extend prev {
  void next() { ++(*self); }
}

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

  struct prev {
    prev & operator++() { return *this; }
    prev operator++(int) { return *this; }
  };

  class null
  {
  };

  class True
  {
  };

  class FALSE
  {
  };

  // PHP 8.1 made `readonly` a keyword, but (unlike any other keyword it seems)
  // it may still be used as a function name.
  namespace ns {
  class readonly { };
  }

  class readonly_should_be_ok_as_method {
  public:
    bool readonly() const { return true; }
  };

  bool readonly() { return false; }
%}
