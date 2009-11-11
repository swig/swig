%module nested_class

#pragma SWIG nowarn=SWIGWARN_PARSE_NESTED_CLASS

%inline %{
struct Outer {
  typedef int Integer;
  ///////////////////////////////////////////
  struct InnerStruct1 {
    Integer x;
  };

  class InnerClass1 {
  public:
    Integer x;
  };

  union InnerUnion1 {
    Integer x;
    double y;
  };

  ///////////////////////////////////////////
  class {
  public:
    Integer a;
  };

  struct {
    Integer b;
  };

  union {
    Integer c;
    double d;
  };

  ///////////////////////////////////////////
  class InnerClass2 {
  public:
    Integer x;
  } InnerClass2Name;

  struct InnerStruct2 {
    Integer x;
  } InnerStruct2Name;

  union InnerUnion2 {
    Integer x;
    double y;
  } InnerUnion2Name;

  ///////////////////////////////////////////
  class {
  public:
    Integer x;
  } InnerClass3Name;

  struct {
    Integer x;
  } InnerStruct3Name;

  union {
    Integer x;
    double y;
  } InnerUnion3Name;

  ///////////////////////////////////////////
  typedef class {
  public:
    Integer x;
  } InnerClass4;

  typedef struct {
    Integer x;
  } InnerStruct4;

  typedef union {
    Integer x;
    double y;
  } InnerUnion4;

  // bug #909387 - inner declared types are treated as forward declarations
  InnerStruct1* getInnerStruct1() { return 0; }
  InnerClass1* getInnerClass1() { return 0; }
  InnerUnion1* getInnerUnion1() { return 0; }

  InnerStruct2* getInnerStruct2() { return 0; }
  InnerClass2* getInnerClass2() { return 0; }
  InnerUnion2* getInnerUnion2() { return 0; }

  InnerStruct4* getInnerStruct4() { return 0; }
  InnerClass4* getInnerClass4() { return 0; }
  InnerUnion4* getInnerUnion4() { return 0; }
};

%}
