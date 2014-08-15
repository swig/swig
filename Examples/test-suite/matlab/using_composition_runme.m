import using_composition.*

f = FooBar();
if (f.blah(3) ~= 3)
  error('FooBar::blah(int)')
end

if (f.blah(3.5) ~= 3.5)
  error('FooBar::blah(double)')
end

if (~strcmp(f.blah('hello'),'hello'))
  error('FooBar::blah(char *)')
end


f = FooBar2();
if (f.blah(3) ~= 3)
  error('FooBar2::blah(int)')
end

if (f.blah(3.5) ~= 3.5)
  error('FooBar2::blah(double)')
end

if (~strcmp(f.blah('hello'),'hello'))
  error('FooBar2::blah(char *)')
end


f = FooBar3();
if (f.blah(3) ~= 3)
  error('FooBar3::blah(int)')
end

if (f.blah(3.5) ~= 3.5)
  error('FooBar3::blah(double)')
end

if (~strcmp(f.blah('hello'),'hello'))
  error('FooBar3::blah(char *)')
end

