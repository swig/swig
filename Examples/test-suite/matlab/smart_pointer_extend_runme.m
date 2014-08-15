import smart_pointer_extend.*

f = Foo();
b = Bar(f);

if (b.extension() ~= f.extension())
  error
end


b = CBase();
d = CDerived();
p = CPtr();

if (b.bar() ~= p.bar())
  error
end

if (d.foo() ~= p.foo())
  error
end

if (b.hello() ~= p.hello())
  error
end



d = DFoo();

dp = DPtrFoo(d);

if (d.SExt(1) ~= dp.SExt(1))
  error
end

if (d.Ext(1) ~= dp.Ext(1))
  error
end

  
