%module memberin_extend_c

#ifdef SWIGFORTRAN
%inline %{
#define GETTER(CLS, VALUE) get_ ## CLS ## _ ## VALUE
#define SETTER(CLS, VALUE) set_ ## CLS ## _ ## VALUE
%}
#else
%inline %{
#define GETTER(CLS, VALUE) CLS ## _ ## VALUE ## _get
#define SETTER(CLS, VALUE) CLS ## _ ## VALUE ## _set
%}
#endif

/* Example from the Manual, section 5.5.6: "Adding member functions to C structures" */

%{
typedef struct {
  char name[50];
} Person;
%}

typedef struct {
  %extend {
    char name[50];
  }
} Person;

%{
#include <ctype.h>
#include <string.h>

void make_upper(char *name) {
  char *c;
  for (c = name; *c; ++c)
    *c = (char)toupper((int)*c);
}

/* Specific implementation of set/get functions forcing capitalization */

char *GETTER(Person, name)(Person *p) {
  make_upper(p->name);
  return p->name;
}

void SETTER(Person, name)(Person *p, char *val) {
  strncpy(p->name,val,50);
  make_upper(p->name);
}
%}
