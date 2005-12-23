from overload_simple_cast import *

class Ai:
    def __init__(self,x):
        self.x = x
        
    def __int__(self):
        return self.x

class Ad:
    def __init__(self,x):
        self.x = x
        
    def __float__(self):
        return self.x

ai = Ai(4)

ad = Ad(5.0)
add = Ad(5.5)

try:
    fint(add)
    good = 0
except:
    good = 1

if not good:
    raise RuntimeError, "fint(int)"    


if fint(ad) != "fint:int":
    raise RuntimeError, "fint(int)"

if fdouble(ad) != "fdouble:double":
    raise RuntimeError, "fdouble(double)"

if fint(ai) != "fint:int":
    raise RuntimeError, "fint(int)"

if fint(5.0) != "fint:int":
    raise RuntimeError, "fint(int)"
    
if fint(3) != "fint:int":
    raise RuntimeError, "fint(int)"
if fint(3.0) != "fint:int":
    raise RuntimeError, "fint(int)"

if fdouble(ad) != "fdouble:double":
    raise RuntimeError, "fdouble(double)"
if fdouble(3) != "fdouble:double":
    raise RuntimeError, "fdouble(double)"
if fdouble(3.0) != "fdouble:double":
    raise RuntimeError, "fdouble(double)"

if fid(3,3.0) != "fid:intdouble":
    raise RuntimeError, "fid:intdouble"

if fid(3.0,3) != "fid:doubleint":
    raise RuntimeError, "fid:doubleint"

if fid(ad,ai) != "fid:doubleint":
    raise RuntimeError, "fid:doubleint"

if fid(ai,ad) != "fid:intdouble":
    raise RuntimeError, "fid:intdouble"



if foo(3) != "foo:int":
    raise RuntimeError, "foo(int)"

if foo(3.0) != "foo:double":
    raise RuntimeError, "foo(double)"

if foo("hello") != "foo:char *":
    raise RuntimeError, "foo(char *)"

f = Foo()
b = Bar()

if foo(f) != "foo:Foo *":
    raise RuntimeError, "foo(Foo *)"

if foo(b) != "foo:Bar *":
    raise RuntimeError, "foo(Bar *)"

v = malloc_void(32)

if foo(v) != "foo:void *":
    raise RuntimeError, "foo(void *)"

s = Spam()

if s.foo(3) != "foo:int":
    raise RuntimeError, "Spam::foo(int)"

if s.foo(3.0) != "foo:double":
    raise RuntimeError, "Spam::foo(double)"

if s.foo("hello") != "foo:char *":
    raise RuntimeError, "Spam::foo(char *)"

if s.foo(f) != "foo:Foo *":
    raise RuntimeError, "Spam::foo(Foo *)"

if s.foo(b) != "foo:Bar *":
    raise RuntimeError, "Spam::foo(Bar *)"

if s.foo(v) != "foo:void *":
    raise RuntimeError, "Spam::foo(void *)"

if Spam_bar(3) != "bar:int":
    raise RuntimeError, "Spam::bar(int)"

if Spam_bar(3.0) != "bar:double":
    raise RuntimeError, "Spam::bar(double)"

if Spam_bar("hello") != "bar:char *":
    raise RuntimeError, "Spam::bar(char *)"

if Spam_bar(f) != "bar:Foo *":
    raise RuntimeError, "Spam::bar(Foo *)"

if Spam_bar(b) != "bar:Bar *":
    raise RuntimeError, "Spam::bar(Bar *)"

if Spam_bar(v) != "bar:void *":
    raise RuntimeError, "Spam::bar(void *)"

# Test constructors

s = Spam()
if s.type != "none":
    raise RuntimeError, "Spam()"

s = Spam(3)
if s.type != "int":
    raise RuntimeError, "Spam(int)"
    
s = Spam(3.4)
if s.type != "double":
    raise RuntimeError, "Spam(double)"

s = Spam("hello")
if s.type != "char *":
    raise RuntimeError, "Spam(char *)"

s = Spam(f)
if s.type != "Foo *":
    raise RuntimeError, "Spam(Foo *)"

s = Spam(b)
if s.type != "Bar *":
    raise RuntimeError, "Spam(Bar *)"

s = Spam(v)
if s.type != "void *":
    raise RuntimeError, "Spam(void *)"





free_void(v)
