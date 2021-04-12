# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

smart_pointer_extend

f = Foo();
b = Bar(f);

if (b.extension() != f.extension())
  error("failed");
endif


b = CBase();
d = CDerived();
p = CPtr();

if (b.bar() != p.bar())
  error("failed");
endif

if (d.foo() != p.foo())
  error("failed");
endif

if (b.hello() != p.hello())
  error("failed");
endif



d = DFoo();

dp = DPtrFoo(d);

if (d.SExt(1) != dp.SExt(1))
  error("failed");
endif

if (d.Ext(1) != dp.Ext(1))
  error("failed");
endif

  
