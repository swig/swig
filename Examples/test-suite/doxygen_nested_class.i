%module doxygen_nested_class

%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) DoxOuter::DoxInner;

%inline %{

struct DoxOuter {
  /** DoxOuter constructor */
  DoxOuter() {}
  /** DoxInner class description */
  struct DoxInner {
    /** DoxInner constructor */
    DoxInner() {}
    /** doxInt variable */
    int doxInt;
    /** doxShort const variable */
    static const short doxShort = 1;
    /** doxMethod description */
    void doxMethod() {}
    /** doxStaticMethod description */
    static void doxStaticMethod() {}
  };
};
%}
