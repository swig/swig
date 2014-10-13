/*
This testcase tests that nested structs/unions work. Named structs/unions declared within
a struct produced redefinition errors in SWIG 1.3.6 as reported by SF bug #447488.
Also tests reported error when a #define placed in a deeply embedded struct/union.
*/

%module nested


#ifdef SWIGSCILAB
%rename(OutStNamed) OuterStructNamed;
%rename(InStNamed) OuterStructUnnamed::InnerStructNamed;
%rename(InUnNamed) OuterStructUnnamed::Inner_union_named;

%rename(OutStUnnamed) OuterStructUnnamed;
%rename(inStUnnamed) OuterStructUnnamed::inner_struct_unnamed;
%rename(inUnUnnamed) OuterStructUnnamed::inner_union_unnamed;

%rename(OutSt) OuterStruct;
%rename(OutNestedSt) OuterStruct::outer_nested_struct;
%rename(InNestedSt) OuterStruct::outer_nested_struct::inner_nested_struct;
%rename(InNestedUn) OuterStruct::outer_nested_struct::innerNestedUnion;
#endif

%inline %{

struct TestStruct {
  int a;
};

struct OuterStructNamed {
  struct InnerStructNamed {
    double dd;
  } inner_struct_named;
  union InnerUnionNamed {
    double ee;
    int ff;
  } inner_union_named;
};

struct OuterStructUnnamed {
  struct {
    double xx;
  } inner_struct_unnamed;
  union {
    double yy;
    int zz;
  } inner_union_unnamed;
};


typedef struct OuterStruct {
  union {

    struct outer_nested_struct {
      union inner_nested_union {
#define BAD_STYLE 1
        int red;
        struct TestStruct green;
      } InnerNestedUnion;

      struct inner_nested_struct {
        int blue;
      } InnerNestedStruct;
    } OuterNestedStruct;

  } EmbeddedUnion;
} OuterStruct;

%}
