import using_extend.*

f = FooBar();
if (f.blah(3) ~= 3)
    error('blah(int)')
end

if (f.blah(3.5) ~= 3.5)
    error('blah(double)')
end

if (~strcmp(f.blah('hello'),'hello'))
    error('blah(char *)')
end

if (f.blah(3,4) ~= 7)
    error('blah(int,int)')
end

if (f.blah(3.5,7.5) ~= (3.5+7.5))
    error('blah(double,double)')
end


if (f.duh(3) ~= 3)
    error('duh(int)')
end
