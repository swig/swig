/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * php4kw.swg
 *
 * The 'keywords' in PHP are global, ie, the following names are fine
 * when used as class methods.
 * ----------------------------------------------------------------------------- */

#define PHPKW(x) %keywordwarn(`x` " is a php keyword, renamed as c_"`x`,sourcefmt="%(lower)s", rename="c_%s",fullname=1)  `x`

%define PHPCN(x) 
%keywordwarn(`x` " is a php reserved class name, class renamed as c_"`x`,%$isclass,rename="c_%s") `x`;
%keywordwarn(`x` " is a php reserved class name, constructor renamed as c_"`x`,%$isconstructor,rename="c_%s") `x`;
%enddef

#define PHPBN1(x) %builtinwarn(`x` " conflicts with a built-in name in php",sourcefmt="%(lower)s",fullname=1)  `x`
#define PHPBN2(x) %builtinwarn(`x` " conflicts with a built-in name in php")  "::" `x`


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

/* we catalog these as built-in names since they conflict, but PHP still runs */

/* Type 1: case insensitive */
PHPBN1(__sleep);
PHPBN1(__wakeup);
PHPBN1(not);
PHPBN1(parent);
PHPBN1(virtual);
PHPBN1(NULL);
PHPBN1(TRUE);
PHPBN1(FALSE);
PHPBN1(__FILE__);
PHPBN1(__LINE__);

/* Type 2: case sensitive */
PHPBN2(E_ALL);
PHPBN2(E_ERROR);
PHPBN2(E_PARSE);
PHPBN2(E_WARNING);
PHPBN2(PHP_OS);
PHPBN2(PHP_VERSION);

/* Class names not allowed */
PHPCN(stdClass);


#undef PHPKW
#undef PHPBN1
#undef PHPBN2
#undef PHPCN
