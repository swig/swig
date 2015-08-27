import cpp_enum.*

f = cpp_enum.Foo();

if (f.hola ~= cpp_enum.Foo.Hello)
     error('incorrect value %d', f.hola);
end

f.hola = cpp_enum.Foo.Hi;
if (f.hola ~= cpp_enum.Foo.Hi)
     error('incorrect value %d', f.hola);
end

f.hola = cpp_enum.Foo.Hello;

if (f.hola ~= cpp_enum.Foo.Hello)
    error('incorrect value %d', f.hola);
end

cpp_enum.hi = cpp_enum.Hello;
if (cpp_enum.hi ~= cpp_enum.Hello)
     error('incorrect value %d', cpp_enum.hi);
end
