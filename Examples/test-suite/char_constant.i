/* This interface file tests whether character constants are correctly
   wrapped as procedures returning Scheme characters (rather than
   Scheme strings). 
*/

%module char_constant

#define CHAR_CONSTANT 'x'

#define STRING_CONSTANT "xyzzy"

#define ESC_CONST  '\1'
#define NULL_CONST '\0'
#define SPECIALCHAR 'á'

%inline 
{
  const int ia = (int)'a';
  const int ib = 'b';
}
