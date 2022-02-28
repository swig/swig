%module rename_camel

%rename("%(utitle)s",%$isfunction,%$ismember) ""; 
%rename("%(ctitle)s",%$isvariable,%$ismember) ""; 

%inline {
  struct GeometryFactory 
  {
    void createPointFromInternalCoord(int);
    void BIG_METHOD(int);
  };  

  class ByteOrderValues {
    
  public:
    void readHEX();
    static int ENDIAN_BIG;
  };
  
}


%rename(CamelCase1) camel_case_1;
%rename("%(camelcase)s") camel_case_2;
%rename("%(ctitle)s") camel_case_3;


%rename("%(utitle)s") CamelCase_5;

%rename("%(regex:/\\(.*i.*\\)/\\U\\1/)s") "";

%rename("%(title)s",regexmatch$parentNode$type="enum .*") "";

%inline 
{
  int camel_case_1(int);
  int camel_case_2(int);
  int camel_case_3(int);
  int camel_case_4(int);
  int camel_case(int);
  int CamelCase_5(int);
  int also_works_here(int);

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



