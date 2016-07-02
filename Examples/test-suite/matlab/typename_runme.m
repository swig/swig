f = typename.Foo();
b = typename.Bar();

x = typename.twoFoo(f);
if (x == floor(x))
    error('Wrong return type~')
end
y = typename.twoBar(b);
if (y ~= floor(y))
    error('Wrong return type~')
end
    
