/* -----------------------------------------------------------------------------
 * python.swg
 *
 * Python configuration module.
 * ----------------------------------------------------------------------------- */

%insert(runtime) "common.swg";
%insert(runtime) "pyrun.swg";

/* Warnings for Python keywords */
#define PYKW(x) %namewarn(#x " is a python keyword")  #x;

PYKW(and)
PYKW(assert)
PYKW(break)
PYKW(class)
PYKW(continue)
PYKW(def)
PYKW(del)
PYKW(elif)
PYKW(else)
PYKW(except)
PYKW(exec)
PYKW(finally)
PYKW(for)
PYKW(from)
PYKW(global)
PYKW(if)
PYKW(import)
PYKW(in)
PYKW(is)
PYKW(lambda)
PYKW(not)
PYKW(or)
PYKW(pass)
PYKW(print)
PYKW(raise)
PYKW(return)
PYKW(try)
PYKW(while)







