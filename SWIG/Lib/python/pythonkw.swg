#ifndef __python_pythonkw_swg__
#define __python_pythonkw_swg__

/* Warnings for Python keywords */
#define PYTHONKW(x) %namewarn("314:" #x " is a python keyword")  #x

PYTHONKW(and);
PYTHONKW(assert);
PYTHONKW(break);
PYTHONKW(class);
PYTHONKW(continue);
PYTHONKW(def);
PYTHONKW(del);
PYTHONKW(elif);
PYTHONKW(else);
PYTHONKW(except);
PYTHONKW(exec);
PYTHONKW(finally);
PYTHONKW(for);
PYTHONKW(from);
PYTHONKW(global);
PYTHONKW(if);
PYTHONKW(import);
PYTHONKW(in);
PYTHONKW(is);
PYTHONKW(lambda);
PYTHONKW(not);
PYTHONKW(or);
PYTHONKW(pass);
PYTHONKW(print);
PYTHONKW(raise);
PYTHONKW(return);
PYTHONKW(try);
PYTHONKW(while);
PYTHONKW(yield);

#undef PYTHONKW

#define PYTHONBN(x) %namewarn("321:" #x " conflicts with a built-in name in python")  "::"#x

/* recurrent built-in functions */
PYTHONBN(close);
PYTHONBN(float);
PYTHONBN(int);
PYTHONBN(input);
PYTHONBN(open);
PYTHONBN(range);
PYTHONBN(type);

/* Boolean type */
PYTHONBN(True);
PYTHONBN(False);

#undef PYTHONBN

#endif //__python_pythonkw_swg__
