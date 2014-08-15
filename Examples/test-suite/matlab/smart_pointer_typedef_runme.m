import smart_pointer_typedef.*

f = Foo();
b = Bar(f);

b.x = 3;
if (b.getx() ~= 3)
  error('Failed!!')
end

fp = b.__deref__();
fp.x = 4;
if (fp.getx() ~= 4)
    error('Failed!!')
end
