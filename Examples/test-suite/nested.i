/*
This testcase tests that nested structs/unions work. Named structs/unions declared within
a struct produced redefinition errors in SWIG 1.3.6 as reported by SF bug #447488.
Also tests reported error when a #define placed in a deeply embedded struct/union.
*/

%module nested


#if defined(SWIGSCILAB)
%rename(OutStNamed) OuterStructNamed;
%rename(InStNamed) OuterStructNamed::InnerStructNamed;
%rename(InUnNamed) OuterStructNamed::Inner_union_named;
#endif

#if defined(SWIG_JAVASCRIPT_V8)

%inline %{
#if __GNUC__ >= 5 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 8)
/* for nested C class wrappers compiled as C++ code */
/* dereferencing type-punned pointer will break strict-aliasing rules [-Werror=strict-aliasing] */
#pragma GCC diagnostic ignored "-Wstrict-aliasing"
#endif
%}

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

%}


%inline %{

struct OutStUnnamed {
  struct {
    double xx;
  } inSt;
  union {
    double yy;
    int zz;
  } inUn;
};

typedef struct OutSt {
  union {

    struct nst_st {
      union in_un {
#define BAD_STYLE 1
        int red;
        struct TestStruct green;
      } InUn;

      struct in_st {
        int blue;
      } InSt;
    } NstdSt;

  } EmbedUn;
} OutSt;

%}


%inline %{
  typedef struct {
    union x_union {
      int x;
    } duplicate_p;
  } x_t;

  typedef struct {
    union y_union {
      int y;
    } duplicate_p;
  } y_t;

  typedef struct A {
    union a_union {
      int a;
    } duplicate_p;
  } a_t;

  typedef struct B {
    union b_union {
      int b;
    } duplicate_p;
  } b_t;

  typedef struct {
    union {
      int c;
    } duplicate_p;
  } c_t;

  typedef struct {
    union {
      int d;
    } duplicate_p;
  } d_t;

  void set_union_values(int startval, x_t *x, y_t *y, a_t *a, b_t *b, c_t *c, d_t *d) {
    x->duplicate_p.x = startval++;
    y->duplicate_p.y = startval++;
    a->duplicate_p.a = startval++;
    b->duplicate_p.b = startval++;
    c->duplicate_p.c = startval++;
    d->duplicate_p.d = startval++;
  }
%}

