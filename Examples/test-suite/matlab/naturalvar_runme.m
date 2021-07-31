f = naturalvar.Foo();
b = naturalvar.Bar();

b.f(f);

naturalvar.s('hello');
b.s = 'hello';

if (b.s ~= naturalvar.s)
    error
end
