#ifndef KOTLIN_KOTLINKW_SWG_
#define KOTLIN_KOTLINKW_SWG_

/* Warnings for Kotlin hard keywords */
#define KOTLINKW(x) %keywordwarn("'" `x` "' is a kotlin keyword",rename="_%s")  `x`

/*
   Hard keywords which are always reserved and cannot be used as identifiers, from
   https://kotlinlang.org/docs/keyword-reference.html
   Soft and modifier keywords (by, catch, get, set, where, open, etc.) can be used
   as identifiers and so are not listed here.
*/

KOTLINKW(as);
KOTLINKW(break);
KOTLINKW(class);
KOTLINKW(continue);
KOTLINKW(do);
KOTLINKW(else);
KOTLINKW(false);
KOTLINKW(for);
KOTLINKW(fun);
KOTLINKW(if);
KOTLINKW(in);
KOTLINKW(interface);
KOTLINKW(is);
KOTLINKW(null);
KOTLINKW(object);
KOTLINKW(package);
KOTLINKW(return);
KOTLINKW(super);
KOTLINKW(this);
KOTLINKW(throw);
KOTLINKW(true);
KOTLINKW(try);
KOTLINKW(typealias);
KOTLINKW(typeof);
KOTLINKW(val);
KOTLINKW(var);
KOTLINKW(when);
KOTLINKW(while);

#undef KOTLINKW

#endif //KOTLIN_KOTLINKW_SWG_
