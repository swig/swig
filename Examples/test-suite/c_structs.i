%module c_structs

// The header declares each struct and union as in this code, run with -namespace, which does not change their names
%inline %{
struct Tagged {
  int a;
};

typedef struct SameName {
  int b;
} SameName;

typedef struct DiffTag {
  int c;
} DiffName;

typedef struct {
  int d;
} Anon;

typedef union Value {
  int i;
  double d;
} Value;

typedef union {
  short s;
  double d;
} AnonValue;

int tagged_get(struct Tagged *p) { return p->a; }
int same_name_get(SameName *p) { return p->b; }
int diff_tag_get(struct DiffTag *p) { return p->c; }
int diff_name_get(DiffName *p) { return p->c; }
int anon_get(Anon *p) { return p->d; }
double value_get(union Value *p) { return p->d; }
double anon_value_get(AnonValue *p) { return p->d; }
%}
