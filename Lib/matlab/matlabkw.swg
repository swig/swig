/*
  Warnings for MATLAB keywords, built-in names and bad names.
*/

#define MATLABKW(x) %keywordwarn("'" `x` "' is a MATLAB keyword, renaming to '" `x` "1'", rename="%s1")  `x`
#define MATLABBN(x) %builtinwarn("'" `x` "' conflicts with a built-in name in MATLAB")  `x`


/*
  MATLAB keywords
*/

MATLABKW(break);
MATLABKW(case);
MATLABKW(catch);
MATLABKW(classdef);
MATLABKW(continue);
MATLABKW(else);
MATLABKW(elseif);
MATLABKW(end);
MATLABKW(for);
MATLABKW(function);
MATLABKW(global);
MATLABKW(if);
MATLABKW(otherwise);
MATLABKW(parfor);
MATLABKW(persistent);
MATLABKW(return);
MATLABKW(spmd);
MATLABKW(switch);
MATLABKW(try);
MATLABKW(while);


/*
   built-in names
*/
MATLABBN(true);
MATLABBN(false);


/*
   'self' is also a bad Name
*/
MATLABKW(self);

#undef MATLABBN
#undef MATLABKW
