#ifndef __python_pythonkw_swg__
#define __python_pythonkw_swg__

/* Warnings for Python keywords */
#define PYKW(x) %namewarn("314:" #x " is a python keyword")  #x

PYKW(and);
PYKW(assert);
PYKW(break);
PYKW(class);
PYKW(continue);
PYKW(def);
PYKW(del);
PYKW(elif);
PYKW(else);
PYKW(except);
PYKW(exec);
PYKW(finally);
PYKW(for);
PYKW(from);
PYKW(global);
PYKW(if);
PYKW(import);
PYKW(in);
PYKW(is);
PYKW(lambda);
PYKW(not);
PYKW(or);
PYKW(pass);
PYKW(print);
PYKW(raise);
PYKW(return);
PYKW(try);
PYKW(while);


#endif //__python_pythonkw_swg__
