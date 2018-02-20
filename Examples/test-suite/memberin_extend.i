%module memberin_extend

// Tests memberin typemap is not used for %extend.
// The test extends the struct with a pseudo member variable

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


%inline %{
#include <string>
struct ExtendMe {
};
%}

%{
#include <map>
#include <string.h>
std::map<ExtendMe*, char *> ExtendMeStringMap;
void SETTER(ExtendMe, thing)(ExtendMe *self, const char *val) {
  char *old_val = ExtendMeStringMap[self];
  delete [] old_val;
  if (val) {
    ExtendMeStringMap[self] = new char[strlen(val)+1];
    strcpy(ExtendMeStringMap[self], val);
  } else {
    ExtendMeStringMap[self] = 0;
  }
}
char * GETTER(ExtendMe, thing)(ExtendMe *self) {
  return ExtendMeStringMap[self];
}
%}

%extend ExtendMe {
  char *thing;
}

