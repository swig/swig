#ifndef __chicken_chickenkw_swg__
#define __chicken_chickenkw_swg__

/* Warnings for certain CHICKEN keywords. From Section 7.1.1 of
   Revised^5 Report on the Algorithmic Language Scheme */
#define CHICKW(x) %namewarn("314:" #x " is a R^5RS syntatic keyword")  #x

CHICKW(else);
CHICKW(=>);
CHICKW(define);
CHICKW(unquote);
CHICKW(unquote-splicing);
CHICKW(quote);
CHICKW(lambda);
CHICKW(if);
CHICKW(set!);
CHICKW(begin);
CHICKW(cond);
CHICKW(and);
CHICKW(or);
CHICKW(case);
CHICKW(let);
CHICKW(let*);
CHICKW(letrec);
CHICKW(do);
CHICKW(delay);
CHICKW(quasiquote);


#endif //__chicken_chickenkw_swg__
