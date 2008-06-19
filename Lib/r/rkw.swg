/*
  Warnings for R keywords, built-in names and bad names.
*/

#define RKW(x) %keywordwarn("'" `x` "' is a R keyword, renaming to '_" `x`"'", rename="_%s")  `x`


/*
  Warnings for R keywords 
  REFERENCE ????
*/

RKW(except);
RKW(in);
RKW(next);

#undef RKW
