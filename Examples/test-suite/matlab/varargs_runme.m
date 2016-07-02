if (~strcmp(varargs.test('Hello'),'Hello'))
    error('Failed')
end

f = varargs.Foo('Greetings');
if (~strcmp(f.str,'Greetings'))
    error('Failed')
end

if (~strcmp(f.test('Hello'),'Hello'))
    error('Failed')
end


if (~strcmp(varargs.test_def('Hello',1),'Hello'))
    error('Failed')
end

if (~strcmp(varargs.test_def('Hello'),'Hello'))
    error('Failed')
end
