#ifndef subdir2_hello_i_
#define subdir2_hello_i_

%{
typedef char * TypedefString;
%}


%inline %{
  
  struct B
  {
  };

  TypedefString importtest2(TypedefString str) {
    strcpy(str, "white");
    return str;
  }

%}


#endif //subdir2_hello_i_
