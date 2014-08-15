import smart_pointer_not.*

f = Foo();
b = Bar(f);
s = Spam(f);
g = Grok(f);

try
    x = b.x;
    error('Error~ b.x')
catch
end

try
    x = s.x;
    error('Error~ s.x')
catch
end

try
    x = g.x;
    error('Error~ g.x')
catch
end

try
    x = b.getx();
    error('Error~ b.getx()')
catch
end

try
    x = s.getx();
    error('Error~ s.getx()')
catch
end

try
    x = g.getx();
    error('Error~ g.getx()')
catch
end
