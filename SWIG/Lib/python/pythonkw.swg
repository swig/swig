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

/*
 bad names
 http://users.ox.ac.uk/~sann1276/python/handbook/node52.html
*/

#define PYTHONBN(x) %namewarn("314:" #x " is a bad name in python")  #x

PYTHONBN(Data);
PYTHONBN(Float);
PYTHONBN(Int);
PYTHONBN(Numeric);
PYTHONBN(Oxphys);
PYTHONBN(array);
PYTHONBN(close);
PYTHONBN(float);
PYTHONBN(int);
PYTHONBN(input);
PYTHONBN(open);
PYTHONBN(range);
PYTHONBN(type);
PYTHONBN(write);
PYTHONBN(zeros);


PYTHONBN(True);
PYTHONBN(False);

#undef PYTHONBN

#endif //__python_pythonkw_swg__
