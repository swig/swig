#ifndef __ruby_rubykw_swg__
#define __ruby_rubykw_swg__

/* Warnings for Ruby keywords */
#define RUBYKW(x) %namewarn("314:" #x " is a ruby keyword")  #x


/*

   from
   http://www.ruby-lang.org/en/man-1.4/syntax.html#resword

*/

RUBYKW(BEGIN);
RUBYKW(class);
RUBYKW(ensure);
RUBYKW(nil);
RUBYKW(self);
RUBYKW(when);
RUBYKW(END);
RUBYKW(def);
RUBYKW(false);
RUBYKW(not);
RUBYKW(super);
RUBYKW(while);
RUBYKW(alias);
RUBYKW(for);
RUBYKW(or);
RUBYKW(then);
RUBYKW(yield);
RUBYKW(and);
RUBYKW(do);
RUBYKW(if);
RUBYKW(redo);
RUBYKW(true);
RUBYKW(begin);
RUBYKW(else);
RUBYKW(in);
RUBYKW(rescue);
RUBYKW(undef);
RUBYKW(break);
RUBYKW(elsif);
RUBYKW(module);
RUBYKW(retry);
RUBYKW(unless);
RUBYKW(case);
RUBYKW(end);
RUBYKW(next);
RUBYKW(return);
RUBYKW(until);

/* swig doesn't like this one */
// RUBYKW(defined);

#endif //__ruby_rubykw_swg__
