%module rename_camel


%define CamelCase "%(command:sed -e 's/\([a-z]\)/\U\\1/' -e 's/\(_\)\([a-z]\)/\U\\2/g' <<< %s)s" %enddef


%rename("CamelCase1") camel_case_1;
%rename("_%s")        camel_case_2;
%rename("%(mangle)s") camel_case_3;
%rename("%(title)s")  camel_case_4;
%rename(CamelCase)    camel_case;
%rename(CamelCase)    also_works_here;

%rename("%(title)s",match="enumitem") "*";


%inline 
{
  int camel_case_1(int);
  int camel_case_2(int);
  int camel_case_3(int);
  int camel_case_4(int);
  int camel_case(int);
  int also_works_here(int);

  enum HelloEnum {
    hi, hello
  };
  
  
}
