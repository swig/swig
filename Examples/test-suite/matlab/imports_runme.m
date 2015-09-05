% This is the import runtime testcase.

import  imports_b.*;
import  imports_a.*;

  x = imports_b.B();
  x.hello();

  a = imports_a.A();

  c = imports_b.C();
  a1 = c.get_a(c);
  a2 = c.get_a_type(c);

  a1.hello();
  a2.hello();
% no swig_this yet
%  assert(swig_this(a1)==swig_this(a2));
%  assert(strcmp(swig_type(a1),swig_type(a2)));
