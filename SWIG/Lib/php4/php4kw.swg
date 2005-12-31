//
// The 'keywords' in PHP are global, ie, the following names are fine
// when used as class methods.
//

#define PHPKW(x) %namewarn("314:" `x` " is a php keyword",rename="_%s")  "::" `x`
#define PHPBN(x) %namewarn("321:" `x` " conflicts with a built-in name in php")  "::" `x`

/*
   From

     http://aspn.activestate.com/ASPN/docs/PHP/reserved.html

   and reviewed by Olly Betts.

*/

/* we catalog these as kw since PHP will not run if used globally */
PHPKW(and);
PHPKW(as);
PHPKW(break);
PHPKW(case);
PHPKW(cfunction);
PHPKW(class);
PHPKW(continue);
PHPKW(declare);
PHPKW(default);
PHPKW(die);
PHPKW(do);
PHPKW(echo);
PHPKW(else);
PHPKW(elseif);
PHPKW(empty);
PHPKW(enddeclare);
PHPKW(endfor);
PHPKW(endforeach);
PHPKW(endif);
PHPKW(endswitch);
PHPKW(endwhile);
PHPKW(eval);
PHPKW(exit);
PHPKW(extends);
PHPKW(for);
PHPKW(foreach);
PHPKW(function);
PHPKW(global);
PHPKW(if);
PHPKW(include);
PHPKW(include_once);
PHPKW(list);
PHPKW(new);
PHPKW(old_function);
PHPKW(or);
PHPKW(print);
PHPKW(require);
PHPKW(require_once);
PHPKW(return);
PHPKW(static);
PHPKW(switch);
PHPKW(var);
PHPKW(while);
PHPKW(xor);

/* we catalog these as built-in names since they conflicts, but PHP still runs */
PHPBN(E_ALL);
PHPBN(E_ERROR);
PHPBN(E_PARSE);
PHPBN(E_WARNING);
PHPBN(FALSE);
PHPBN(PHP_OS);
PHPBN(PHP_VERSION);
PHPBN(TRUE);
PHPBN(__sleep);
PHPBN(__wakeup);

#undef PHPKW
#undef PHPBN


