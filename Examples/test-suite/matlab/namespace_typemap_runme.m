import namespace_typemap.*

if (~strcmp(stest1('hello'),'hello'))
    error
end

if (~strcmp(stest2('hello'),'hello'))
    error
end

if (~strcmp(stest3('hello'),'hello'))
    error
end

if (~strcmp(stest4('hello'),'hello'))
    error
end

if (~strcmp(stest5('hello'),'hello'))
    error
end

if (~strcmp(stest6('hello'),'hello'))
    error
end

if (~strcmp(stest7('hello'),'hello'))
    error
end

if (~strcmp(stest8('hello'),'hello'))
    error
end

if (~strcmp(stest9('hello'),'hello'))
    error
end

if (~strcmp(stest10('hello'),'hello'))
    error
end

if (~strcmp(stest11('hello'),'hello'))
    error
end

if (~strcmp(stest12('hello'),'hello'))
    error
end

c = complex(2,3);
r = real(c);

if (ctest1(c) ~= r)
    error
end

if (ctest2(c) ~= r)
    error
end

if (ctest3(c) ~= r)
    error
end

if (ctest4(c) ~= r)
    error
end

if (ctest5(c) ~= r)
    error
end

if (ctest6(c) ~= r)
    error
end

if (ctest7(c) ~= r)
    error
end

if (ctest8(c) ~= r)
    error
end

if (ctest9(c) ~= r)
    error
end

if (ctest10(c) ~= r)
    error
end

if (ctest11(c) ~= r)
    error
end

if (ctest12(c) ~= r)
    error
end

try
    ttest1(-14)
    error
catch
end
