%module nested_class

#pragma SWIG nowarn=SWIGWARN_PARSE_UNNAMED_NESTED_CLASS
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerStruct1;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerClass1;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerUnion1;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerClass2;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerStruct2;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerUnion2;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerClass4Typedef;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerStruct4Typedef;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerUnion4Typedef;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerClass5;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerStruct5;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerUnion5;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerMultiple;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerMultipleDerived;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerMultipleAnonTypedef1;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerMultipleNamedTypedef;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer::InnerSameName;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer2::IgnoreMe;

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
#ifdef SWIG
/* some compilers do not accept these */
  class {
  public:
    Integer a;
  };

  struct {
    Integer b;
  };
#endif

  union {
    Integer c;
    double d;
  };

  ///////////////////////////////////////////
  class InnerClass2 {
  public:
    Integer x;
  } InnerClass2Instance;

  struct InnerStruct2 {
    Integer x;
  } InnerStruct2Instance;

  union InnerUnion2 {
    Integer x;
    double y;
  } InnerUnion2Instance;

  ///////////////////////////////////////////
  class {
  public:
    Integer x;
  } InnerClass3Instance;

  struct {
    Integer x;
  } InnerStruct3Instance;

  union {
    Integer x;
    double y;
  } InnerUnion3Instance;

  ///////////////////////////////////////////
  typedef class {
  public:
    Integer x;
  } InnerClass4Typedef;

  typedef struct {
    Integer x;
  } InnerStruct4Typedef;

  typedef union {
    Integer x;
    double y;
  } InnerUnion4Typedef;

  ///////////////////////////////////////////
  typedef class InnerClass5 {
  public:
    Integer x;
  } InnerClass5Typedef;

  typedef struct InnerStruct5 {
    Integer x;
  } InnerStruct5Typedef;

  typedef union InnerUnion5 {
    Integer x;
    double y;
  } InnerUnion5Typedef;

  // bug #909387 - inner declared types are treated as forward declarations
  InnerStruct1* makeInnerStruct1() { return 0; }
  InnerClass1* makeInnerClass1() { return 0; }
  InnerUnion1* makeInnerUnion1() { return 0; }

  InnerStruct2* makeInnerStruct2() { return 0; }
  InnerClass2* makeInnerClass2() { return 0; }
  InnerUnion2* makeInnerUnion2() { return 0; }

  InnerStruct4Typedef* makeInnerStruct4Typedef() { return 0; }
  InnerClass4Typedef* makeInnerClass4Typedef() { return 0; }
  InnerUnion4Typedef* makeInnerUnion4Typedef() { return 0; }

  InnerStruct5* makeInnerStruct5() { return 0; }
  InnerClass5* makeInnerClass5() { return 0; }
  InnerUnion5* makeInnerUnion5() { return 0; }

  InnerStruct5Typedef* makeInnerStruct5Typedef() { return 0; }
  InnerClass5Typedef* makeInnerClass5Typedef() { return 0; }
  InnerUnion5Typedef* makeInnerUnion5Typedef() { return 0; }

  ///////////////////////////////////////////
  struct InnerMultiple {
    Integer x;
  } MultipleInstance1, MultipleInstance2, *MultipleInstance3, MultipleInstance4[2];

  struct InnerMultipleDerived : public InnerMultiple {
    Integer xx;
  } MultipleDerivedInstance1, MultipleDerivedInstance2, *MultipleDerivedInstance3, MultipleDerivedInstance4[2];

  struct {
    Integer x;
  } MultipleInstanceAnon1, MultipleInstanceAnon2, *MultipleInstanceAnon3, MultipleInstanceAnon4[2];

  struct : public InnerMultiple {
    Integer xx;
  } MultipleInstanceAnonDerived1, MultipleInstanceAnonDerived2, *MultipleInstanceAnonDerived3, MultipleInstanceAnonDerived4[2];

#ifdef SWIG
/* some compilers do not accept these */
  struct : public InnerMultiple {
    Integer xx;
  };

  class : public InnerMultiple {
  public:
    Integer yy;
  };
#endif

  ///////////////////////////////////////////
  typedef struct {
    Integer x;
  } InnerMultipleAnonTypedef1, InnerMultipleAnonTypedef2, *InnerMultipleAnonTypedef3;

  InnerMultipleAnonTypedef1* makeInnerMultipleAnonTypedef1() { return 0; }
  InnerMultipleAnonTypedef2* makeInnerMultipleAnonTypedef2() { return 0; }
  InnerMultipleAnonTypedef3* makeInnerMultipleAnonTypedef3() { return 0; }

  typedef struct InnerMultipleNamedTypedef {
    Integer x;
  } InnerMultipleNamedTypedef1, InnerMultipleNamedTypedef2, *InnerMultipleNamedTypedef3;

  InnerMultipleNamedTypedef* makeInnerMultipleNamedTypedef() { return 0; }
  InnerMultipleNamedTypedef1* makeInnerMultipleNamedTypedef1() { return 0; }
  InnerMultipleNamedTypedef2* makeInnerMultipleNamedTypedef2() { return 0; }
  InnerMultipleNamedTypedef3* makeInnerMultipleNamedTypedef3() { return 0; }

  ///////////////////////////////////////////
  typedef struct InnerSameName {
    Integer x;
  } InnerSameName;

  InnerSameName* makeInnerSameName() { return 0; }
};
%}

// Ignore nested struct instance
%ignore Outer2::IgnoreMeInstance;
%{
struct Outer2 {
  struct IgnoreMe {
    int xx;
  };
};
%}

struct Outer2 {
  struct IgnoreMe {
    int xx;
  } IgnoreMeInstance;
};


