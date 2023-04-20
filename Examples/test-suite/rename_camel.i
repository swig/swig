%module rename_camel

%rename("%(utitle)s",%$isfunction,%$ismember) ""; 
%rename("%(ctitle)s",%$isvariable,%$ismember) ""; 

%inline {
  struct GeometryFactory {
    void createPointFromInternalCoord(int) {}
    void BIG_METHOD(int) {}
  };  

  class ByteOrderValues {
    
  public:
    void readHEX() {}
    static int ENDIAN_BIG;
  };
  
  int ByteOrderValues::ENDIAN_BIG = 4321;
}

%rename(CamelCase1) camel_case_1;
%rename("%(camelcase)s") camel_case_2;
// ctitle is an alias for camelcase.
%rename("%(ctitle)s") camel_case_3;

%rename(lowerCamelCase1) Lower_camel_case_1;
%rename("%(lowercamelcase)s") Lower_camel_case_2;
// lctitle is an alias for lowercamelcase.
%rename("%(lctitle)s") Lower_camel_case_3;

%rename(under_case1) UnderCase1;
%rename("%(undercase)s") UnderCase2;
// utitle is an alias for undercase.
%rename("%(utitle)s") UnderCase3;

// This should change "import" to "Import", but "hi_there" should be handled by
// the rule below and become "HI_THERE".
%rename("%(regex:/(.*i.*)/\\u\\1/)s") "";

%rename("%(upper)s",regexmatch$parentNode$type="enum .*") "";

%inline 
{
  void CamelCase(int) {}
  void camel_case_1(int) {}
  void camel_case_2(int) {}
  void camel_case_3(int) {}

  void under_case(int) {}
  void UnderCase1(int) {}
  void UnderCase2(int) {}
  void UnderCase3(int) {}

  void lowerCamelCase(int) {}
  void Lower_camel_case_1(int) {}
  void Lower_camel_case_2(int) {}
  void Lower_camel_case_3(int) {}

  enum HelloEnum {
    hello, hi_there
  };

  enum ChaoEnum {
    bye, see_you
  };

  void import(int) {}
  void foo(int) {}
}

%rename("%(lowercase)s",sourcefmt="%(regex:/GSL_(.*)/\\1/)s",%$isfunction) "";
%inline {
  void GSL_Hello() {}
}
