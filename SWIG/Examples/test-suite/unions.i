/*
This testcase checks that unions can be set and read.
*/

%module unions
%pragma make_default

%inline %{

typedef struct SmallStruct {
  short         jill;
} SmallStruct;

typedef struct BigStruct {
  int           jack;
  SmallStruct   smallstruct;
} BigStruct;

/* This union is just to check the parser */
typedef union {
  BigStruct     bs;
  SmallStruct   ss;
} UnionTest;

/* This union checks the parser and will be used in a runtime test */
typedef struct {
  union
  {
    BigStruct   big;
    SmallStruct small;
  } uni;
  int           number;
} EmbeddedUnionTest;

%}
