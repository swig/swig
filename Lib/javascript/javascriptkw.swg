#ifndef JAVASCRIPT_JAVASCRIPTKW_SWG_
#define JAVASCRIPT_JAVASCRIPTKW_SWG_

/* Warnings for Javascript keywords: note that we allow the use of keywords for members, as they're used as property names in JS and properties don't conflict with keywords. */
#define JAVASCRIPTKW(x) %keywordwarn("'" `x` "' is a javascript keyword, renaming to '_"`x`"'",%$not %$ismember,rename="_%s")  `x`

/* Taken from https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Lexical_grammar#keywords */
/* This the union of all currently reserved keywords in ECMAScript 4 to 6 in both sloppy and strict mode */

JAVASCRIPTKW(arguments);
JAVASCRIPTKW(await);
JAVASCRIPTKW(break);
JAVASCRIPTKW(case);
JAVASCRIPTKW(catch);
JAVASCRIPTKW(class);
JAVASCRIPTKW(const);
JAVASCRIPTKW(continue);
JAVASCRIPTKW(debugger);
JAVASCRIPTKW(default);
JAVASCRIPTKW(delete);
JAVASCRIPTKW(do);
JAVASCRIPTKW(else);
JAVASCRIPTKW(enum);
JAVASCRIPTKW(eval);
JAVASCRIPTKW(export);
JAVASCRIPTKW(extends);
JAVASCRIPTKW(false);
JAVASCRIPTKW(finally);
JAVASCRIPTKW(for);
JAVASCRIPTKW(function);
JAVASCRIPTKW(if);
JAVASCRIPTKW(implements);
JAVASCRIPTKW(import);
JAVASCRIPTKW(in);
JAVASCRIPTKW(instanceof);
JAVASCRIPTKW(interface);
JAVASCRIPTKW(let);
JAVASCRIPTKW(new);
JAVASCRIPTKW(null);
JAVASCRIPTKW(package);
JAVASCRIPTKW(private);
JAVASCRIPTKW(protected);
JAVASCRIPTKW(public);
JAVASCRIPTKW(return);
JAVASCRIPTKW(static);
JAVASCRIPTKW(super);
JAVASCRIPTKW(switch);
JAVASCRIPTKW(this);
JAVASCRIPTKW(throw);
JAVASCRIPTKW(try);
JAVASCRIPTKW(typeof);
JAVASCRIPTKW(var);
JAVASCRIPTKW(void);
JAVASCRIPTKW(while);
JAVASCRIPTKW(with);
JAVASCRIPTKW(yield);

/* others bad names if any*/
// for example %namewarn("321:clone() is a javascript bad method name") *::clone();

#undef JAVASCRIPTKW

#endif //JAVASCRIPT_JAVASCRIPTKW_SWG_
