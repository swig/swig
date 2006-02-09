#ifndef __ruby_rubykw_swg__
#define __ruby_rubykw_swg__

/* Warnings for Ruby keywords */
#define RUBYKW(x) %keywordwarn("'" `x` "' is a ruby keyword, and it will renamed as 'C_"`x`"'",rename="C_%s",fullname=1)  `x`

/*

   from
   http://www.ruby-lang.org/en/man-1.4/syntax.html#resword

*/

RUBYKW(BEGIN);
RUBYKW(END);
RUBYKW(alias);
RUBYKW(and);
RUBYKW(begin);
RUBYKW(break);
RUBYKW(case);
RUBYKW(class);
RUBYKW(def);
RUBYKW("defined");
RUBYKW(do);
RUBYKW(else);
RUBYKW(elsif);
RUBYKW(end);
RUBYKW(ensure);
RUBYKW(false);
RUBYKW(for);
RUBYKW(if);
RUBYKW(in);
RUBYKW(module);
RUBYKW(next);
RUBYKW(nil);
RUBYKW(not);
RUBYKW(or);
RUBYKW(redo);
RUBYKW(rescue);
RUBYKW(retry);
RUBYKW(return);
RUBYKW(self);
RUBYKW(super);
RUBYKW(then);
RUBYKW(true);
RUBYKW(undef);
RUBYKW(unless);
RUBYKW(until);
RUBYKW(when);
RUBYKW(while);
RUBYKW(yield);


#undef RUBYKW

#endif //__ruby_rubykw_swg__
