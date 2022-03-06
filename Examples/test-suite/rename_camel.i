%module rename_camel

%rename("%(utitle)s",%$isfunction,%$ismember) ""; 
%rename("%(ctitle)s",%$isvariable,%$ismember) ""; 

%inline {
  struct GeometryFactory {
    void createPointFromInternalCoord(int);
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

// This should upper-case "import", but "hi_there" should be handled by the
// rule below and become "Hi_there".
%rename("%(regex:/(.*i.*)/\\U\\1/)s") "";

%rename("%(title)s",regexmatch$parentNode$type="enum .*") "";

%inline 
{
  int CamelCase(int);
  int camel_case_1(int);
  int camel_case_2(int);
  int camel_case_3(int);

  int under_case(int);
  int UnderCase1(int);
  int UnderCase2(int);
  int UnderCase3(int);

  int lowerCamelCase(int);
  int Lower_camel_case_1(int);
  int Lower_camel_case_2(int);
  int Lower_camel_case_3(int);

  enum HelloEnum {
    hello, hi_there
  };

  enum ChaoEnum {
    bye, see_you
  };

  int import(int);
  int foo(int);
  
}

%rename("%(lowercase)s",sourcefmt="%(regex:/GSL_(.*)/\\1/)s",%$isfunction) "";
%inline {
  void GSL_Hello() {}
}



