#ifndef subdir2_hello_i_
#define subdir2_hello_i_

%{
typedef char * TypedefString;
#include <string.h>
%}


%inline %{
  
  struct B
  {
    int bb;
  };

  TypedefString importtest2(TypedefString str) {
    static char result[] = "white";
    return strcmp(str, "black") == 0 ? result : str;
  }

%}


#endif //subdir2_hello_i_
