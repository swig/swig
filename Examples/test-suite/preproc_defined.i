%module preproc_defined

// Check 'defined' passes through the preprocessor without being processed like '#if defined(ABC)' would be (SF bug #1940536)

%define DEFINED_MACRO
%{
  int defined(int b) { 
    return b > 10;
  }
  int vvv = -1;
  void fn(int val) {
    if (defined(val))
      vvv = 1;
    else
      vvv = 0; 
  }
%}
%enddef

DEFINED_MACRO

%{
int checking(void) {
  fn(11);
  int okay = (vvv == 1);
  fn(9);
  okay = okay && (vvv == 0);
  return okay; /* should be 1 */
}
%}

%inline %{
int call_checking(void) {
  return checking();
}
%}
