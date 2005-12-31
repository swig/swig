#ifndef __php_phpkw_swg__
#define __php_phpkw_swg__

/* Warnings for Php keywords */
#define PHPKW(x) %namewarn("314:" `x` " is a php keyword")  `x`
#define PHPBN(x) %namewarn("321:" `x` " conflicts with a built-in name in php")  "::" `x`

/*
   from
   http://aspn.activestate.com/ASPN/docs/PHP/reserved.html

*/


PHPKW(and);
PHPKW($argc);
PHPKW($argv);
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
PHPKW(E_ALL);
PHPKW(echo);
PHPKW(E_ERROR);
PHPKW(else);
PHPKW(elseif);
PHPKW(enddeclare);
PHPKW(endfor);
PHPKW(endforeach);
PHPKW(endif);
PHPKW(endswitch);
PHPKW(endwhile);
PHPKW(E_PARSE);
PHPKW(eval);
PHPKW(E_WARNING);
PHPKW(exit);
PHPKW(extends);
PHPKW(FALSE);
PHPKW(__FILE__);
PHPKW(for);
PHPKW(foreach);
PHPKW(function);
PHPKW(global);
PHPKW($HTTP_COOKIE_VARS);
PHPKW($HTTP_ENV_VARS);
PHPKW($HTTP_GET_VARS);
PHPKW($HTTP_POST_FILES);
PHPKW($HTTP_POST_VARS);
PHPKW($HTTP_SERVER_VARS);
PHPKW(if);
PHPKW(include);
PHPKW(include_once);
PHPKW(__LINE__);
PHPKW(list);
PHPKW(new);
PHPKW(not);
PHPKW(NULL);
PHPKW(old_function);
PHPKW(or);
PHPKW(parent);
PHPKW(PHP_OS);
PHPKW($PHP_SELF);
PHPKW(PHP_VERSION);
PHPKW(require);
PHPKW(require_once);
PHPKW(return);
PHPKW(__sleep);
PHPKW(static);
PHPKW(stdClass);
PHPKW(switch);
PHPKW($this);
PHPKW(TRUE);
PHPKW(var);
PHPKW(virtual);
PHPKW(__wakeup);
PHPKW(while);
PHPKW(xor);


// These are bad names only if global.
PHPBN(empty);
PHPBN(print);


#undef PHPKW

#endif //__php_phpkw_swg__
