/*
  Warnings for Python keywords, built-in names and bad names.
*/

#define PYTHONKW(x) %keywordwarn("'" `x` "' is a python keyword", rename="_%s")  `x`
#define PYTHONBN(x) %builtinwarn("'" `x` "' conflicts with a built-in name in python")  `x`


/*
  Warnings for Python keywords 
  https://docs.python.org/3/reference/lexical_analysis.html#keywords
*/

PYTHONBN(True);
PYTHONBN(False);
PYTHONKW(None);
PYTHONKW(and);
PYTHONKW(as);
PYTHONKW(assert);
PYTHONKW(async);
PYTHONKW(await);
PYTHONKW(break);
PYTHONKW(class);
PYTHONKW(continue);
PYTHONKW(def);
PYTHONKW(del);
PYTHONKW(elif);
PYTHONKW(else);
PYTHONKW(except);
PYTHONKW(finally);
PYTHONKW(for);
PYTHONKW(from);
PYTHONKW(global);
PYTHONKW(if);
PYTHONKW(import);
PYTHONKW(in);
PYTHONKW(is);
PYTHONKW(lambda);
PYTHONKW(nonlocal);
PYTHONKW(not);
PYTHONKW(or);
PYTHONKW(pass);
PYTHONKW(raise);
PYTHONKW(return);
PYTHONKW(try);
PYTHONKW(while);
PYTHONKW(with);
PYTHONKW(yield);

/*
  built-in functions
  https://docs.python.org/3/library/functions.html
 */ 

PYTHONBN(abs);
PYTHONBN(all);
PYTHONBN(any);
PYTHONBN(ascii);
PYTHONBN(bin);
PYTHONBN(bool);
PYTHONBN(bytearray);
PYTHONBN(bytes);
PYTHONBN(callable);
PYTHONBN(chr);
PYTHONBN(classmethod);
PYTHONBN(compile);
PYTHONBN(complex);
PYTHONBN(delattr);
PYTHONBN(dict);
PYTHONBN(dir);
PYTHONBN(divmod);
PYTHONBN(enumerate);
PYTHONBN(eval);
PYTHONBN(exec);
PYTHONBN(filter);
PYTHONBN(float);
PYTHONBN(format);
PYTHONBN(frozenset);
PYTHONBN(getattr);
PYTHONBN(globals);
PYTHONBN(hasattr);
PYTHONBN(hash);
PYTHONBN(help);
PYTHONBN(hex);
PYTHONBN(id);
PYTHONBN(input);
PYTHONBN(int);
PYTHONBN(isinstance);
PYTHONBN(issubclass);
PYTHONBN(iter);
PYTHONBN(len);
PYTHONBN(list);
PYTHONBN(locals);
PYTHONBN(map);
PYTHONBN(max);
PYTHONBN(memoryview);
PYTHONBN(min);
PYTHONBN(next);
PYTHONBN(object);
PYTHONBN(oct);
PYTHONBN(open);
PYTHONBN(ord);
PYTHONBN(pow);
PYTHONBN(print);
PYTHONBN(property);
PYTHONBN(range);
PYTHONBN(repr);
PYTHONBN(reversed);
PYTHONBN(round);
PYTHONBN(set);
PYTHONBN(setattr);
PYTHONBN(slice);
PYTHONBN(sorted);
PYTHONBN(staticmethod);
PYTHONBN(str);
PYTHONBN(sum);
PYTHONBN(super);
PYTHONBN(tuple);
PYTHONBN(type);
PYTHONBN(vars);
PYTHONBN(zip);

/* 
   'self' is also a bad Name
*/
PYTHONKW(self);

#undef PYTHONBN
#undef PYTHONKW
