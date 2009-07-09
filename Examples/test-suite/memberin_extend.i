%module memberin_extend

// Tests memberin typemap. The default char * memberin typemap will be used.
// The test extends the struct with a pseudo member variable

%inline %{
#include <string>
struct ExtendMe {
};
%}

%{
#include <map>
std::map<ExtendMe*, char *> ExtendMeStringMap;
#define ExtendMe_thing_set(self_, val_) ExtendMeStringMap[self_]
#define ExtendMe_thing_get(self_) ExtendMeStringMap[self_]
%}

%extend ExtendMe {
  char *thing;
}

