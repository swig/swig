%module preproc_line_file

// Test __LINE__ and __FILE__ (don't change line numbering in here else runtime tests will need modifying)
#define MYLINE __LINE__
#define MYLINE_ADJUSTED __LINE__ + 100 

#define MYFILE __FILE__
#define MYFILE_ADJUSTED __FILE__ ".bak"


#define STRINGNUM_HELP(a,b) #a#b
#define STRINGNUM(a,b) STRINGNUM_HELP(a,b)
#define STRINGNUM_UNIQUE(a) STRINGNUM(a,__LINE__)

#define MY_STRINGNUM_A STRINGNUM_UNIQUE(my)
#define MY_STRINGNUM_B STRINGNUM_UNIQUE(my)


#define NUMBER_HELP(a,b) a##b
#define NUMBER(a,b) NUMBER_HELP(a,b)
#define NUMBER_UNIQUE(a) NUMBER(a,__LINE__)

%{
const int thing27 = -1;
const int thing28 = -2;
%}
const int NUMBER_UNIQUE(thing) = -1; /* resolves to thing27 */
const int NUMBER_UNIQUE(thing) = -2; /* resolves to thing28 */

#define MYLINE2 __LINE__

%javaconst(1);
%{
struct SillyStruct {
  int num;
  /* static const int line_num = __LINE__; */
};
%}
struct SillyStruct {
  int num;
  static const int LINE_NUMBER = __LINE__; /* This is a C test case, but we can still use a C++ feature to wrap a constant to test __LINE__ here */
};

#define SILLY_CLASS struct SillyMacroClass { int num; static const int LINE_NUM = __LINE__; };
SILLY_CLASS

%{
#define SILLY_CLASS struct SillyMacroClass { int num; };
SILLY_CLASS
%}


