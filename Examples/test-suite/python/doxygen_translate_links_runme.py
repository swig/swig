import doxygen_translate_links
import inspect
import string
import sys
import comment_verifier


comment_verifier.check(inspect.getdoc(doxygen_translate_links.function),
r"""Testing typenames converting in @ link

superFunc(int,std::string)
Test for std_string member


superFunc(int,long,void*)
Test for simple types


superFunc(Shape::superType*)
Test for custom types


superFunc(int**[13])
Test for complex types


same works for 'See also:' links:

See also: superFunc(int,std::string)
See also: superFunc(int,long,void*)
See also: superFunc(Shape::superType*)
See also: superFunc(int**[13])

some failing params:

See also: superFunc()
See also: superFunc()
See also: superFunc()""")
