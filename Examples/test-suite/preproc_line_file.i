%module preproc_line_file
%javaconst(1);
// Test __LINE__ and __FILE__ (don't change line numbers in here else runtime tests will need modifying)
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

#define MYLINE2 __LINE__

/*
TODO: __LINE__ is wrong 
struct Struct {
  static const int line_num = __LINE__;
};
const int NUMBER_UNIQUE(thing) = 0;
const int NUMBER_UNIQUE(thingamebob) = 0;
#define MYLINE3 __LINE__
*/
