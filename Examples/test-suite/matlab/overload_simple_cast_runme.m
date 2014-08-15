import overload_simple_cast.*

Ai=@(x) subclass('x',x,'__int',@(self) self.x);
Ad=@(x) subclass('x',x,'__float',@(self) self.x);

ai = Ai(4);

ad = Ad(5.0);
add = Ad(5.5);

try
    fint(add);
    good = 0;
catch
    good = 1;
end

if (~good)
    error('fint(int)')
end


if (~strcmp(fint(ad),'fint:int'))
    error('fint(int)')
end

if (~strcmp(fdouble(ad),'fdouble:double'))
    error('fdouble(double)')
end

if (~strcmp(fint(ai),'fint:int'))
    error('fint(int)')
end

if (~strcmp(fint(5.0),'fint:int'))
    error('fint(int)')
end
    
if (~strcmp(fint(3),'fint:int'))
    error('fint(int)')
end
if (~strcmp(fint(3.0),'fint:int'))
    error('fint(int)')
end

if (~strcmp(fdouble(ad),'fdouble:double'))
    error('fdouble(double)')
end
if (~strcmp(fdouble(3),f'fdouble:double'))
    error('fdouble(double)')
end
if (~strcmp(fdouble(3.0),'fdouble:double'))
    error('fdouble(double)')
end

if (~strcmp(fid(3,3.0),'fid:intdouble'))
    error('fid:intdouble')
end

if (~strcmp(fid(3.0,3),'fid:doubleint'))
    error('fid:doubleint')
end

if (~strcmp(fid(ad,ai),'fid:doubleint'))
    error('fid:doubleint')
end

if (~strcmp(fid(ai,ad),'fid:intdouble'))
    error('fid:intdouble')
end



if (~strcmp(foo(3),'foo:int'))
    error('foo(int)')
end

if (~strcmp(foo(3.0),'foo:double'))
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

if (~strcmp(s.foo(3.0),'foo:double'))
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

if (~strcmp(Spam_bar(3.0),'bar:double'))
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


% unsigned long long
ullmax = 9223372036854775807; %0xffffffffffffffff
ullmaxd = 9007199254740992.0;
ullmin = 0;
ullmind = 0.0;
if (ull(ullmin) ~= ullmin)
    error('ull(ullmin)')
end
if (ull(ullmax) ~= ullmax)
    error('ull(ullmax)')
end
if (ull(ullmind) ~= ullmind)
    error('ull(ullmind)')
end
if (ull(ullmaxd) ~= ullmaxd)
    error('ull(ullmaxd)')
end

% long long
llmax = 9223372036854775807; %0x7fffffffffffffff
llmin = -9223372036854775808;
% these are near the largest  floats we can still convert into long long
llmaxd = 9007199254740992.0;
llmind = -9007199254740992.0;
if (ll(llmin) ~= llmin)
    error('ll(llmin)')
end
if (ll(llmax) ~= llmax)
    error('ll(llmax)')
end
if (ll(llmind) ~= llmind)
    error('ll(llmind)')
end
if (ll(llmaxd) ~= llmaxd)
    error('ll(llmaxd)')
end

free_void(v);

