import overload_simple.*

% unless explicitly casted via {{u}int{8,16,32,64},double,single},
% octave will take numeric literals as doubles.

if (~strcmp(foo(3),'foo:int'))
    error('foo(int)')
end

if (~strcmp(foo(3.1),'foo:double'))
    error('foo(double)')
end

if (~strcmp(foo('hello'),'foo:char *'))
    error('foo(char *)')
end

f = Foo();
b = Bar();

if (~strcmp(foo(f),'foo:Foo *'))
    error('foo(Foo *)')
end

if (~strcmp(foo(b),'foo:Bar *'))
    error('foo(Bar *)')
end

v = malloc_void(32);

if (~strcmp(foo(v),'foo:void *'))
    error('foo(void *)')
end

s = Spam();

if (~strcmp(s.foo(3),'foo:int'))
    error('Spam::foo(int)')
end

if (~strcmp(s.foo(3.1),'foo:double'))
    error('Spam::foo(double)')
end

if (~strcmp(s.foo('hello'),'foo:char *'))
    error('Spam::foo(char *)')
end

if (~strcmp(s.foo(f),'foo:Foo *'))
    error('Spam::foo(Foo *)')
end

if (~strcmp(s.foo(b),'foo:Bar *'))
    error('Spam::foo(Bar *)')
end

if (~strcmp(s.foo(v),'foo:void *'))
    error('Spam::foo(void *)')
end

if (~strcmp(Spam_bar(3),'bar:int'))
    error('Spam::bar(int)')
end

if (~strcmp(Spam_bar(3.1),'bar:double'))
    error('Spam::bar(double)')
end

if (~strcmp(Spam_bar('hello'),'bar:char *'))
    error('Spam::bar(char *)')
end

if (~strcmp(Spam_bar(f),'bar:Foo *'))
    error('Spam::bar(Foo *)')
end

if (~strcmp(Spam_bar(b),'bar:Bar *'))
    error('Spam::bar(Bar *)')
end

if (~strcmp(Spam_bar(v),'bar:void *'))
    error('Spam::bar(void *)')
end

% Test constructors

s = Spam();
if (~strcmp(s.type,'none'))
    error('Spam()')
end

s = Spam(3);
if (~strcmp(s.type,'int'))
    error('Spam(int)')
end
    
s = Spam(3.4);
if (~strcmp(s.type,'double'))
    error('Spam(double)')
end

s = Spam('hello');
if (~strcmp(s.type,'char *'))
    error('Spam(char *)')
end

s = Spam(f);
if (~strcmp(s.type,'Foo *'))
    error('Spam(Foo *)')
end

s = Spam(b);
if (~strcmp(s.type,'Bar *'))
    error('Spam(Bar *)')
end

s = Spam(v);
if (~strcmp(s.type,'void *'))
    error('Spam(void *)')
end

free_void(v);

a = ClassA();
b = a.method1(1);
