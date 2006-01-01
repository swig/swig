%module rename_camel


%define SedCmd "%(command:sed -e 's/\([a-z]\)/\U\\1/' -e 's/\(_\)\([a-z]\)/\U\\2/g' <<<)s" %enddef

%rename(CamelCase1) camel_case_1;
%rename(SedCmd)     camel_case_2;
%rename("%(ctitle)s") camel_case_3;

%rename("%(title)s",match$parentNode$type="enum HelloEnum") "";
%rename("%(ctitle)s",match$parentNode$type="enum ChaoEnum") "";

#define awk_cmd "%(command:awk '/^i/{print toupper($1)}' <<<)s"

%rename(awk_cmd) "";

%inline 
{
  int camel_case_1(int);
  int camel_case_2(int);
  int camel_case_3(int);
  int camel_case_4(int);
  int camel_case(int);
  int also_works_here(int);

  enum HelloEnum {
    hello, hi_there
  };
  

  enum ChaoEnum {
    bye, see_you
  };

  int import(int);
  int foo(int);
  
}
