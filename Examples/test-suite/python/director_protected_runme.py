from director_protected import *



class FooBar(Bar):
  def ping(self):
    return "FooBar::ping();"

class FooBar2(Bar):
  def ping(self):
    return "FooBar2::ping();"
  def pang(self):
    return "FooBar2::pang();"


b  = Bar()
f  = b.create()
fb = FooBar()
fb2 = FooBar2()


try:
  s = fb.used()
  if s != "Foo::pang();Bar::pong();Foo::pong();FooBar::ping();":
    raise RuntimeError
  pass
except:
  raise RuntimeError, "bad FooBar::used"

try:
  s = fb2.used()
  if s != "FooBar2::pang();Bar::pong();Foo::pong();FooBar2::ping();":
    raise RuntimeError
  pass
except:
  raise RuntimeError, "bad FooBar2::used"

try:
  s = b.pong()
  if s != "Bar::pong();Foo::pong();Bar::ping();":
    raise RuntimeError
  pass
except:
  raise RuntimeError, "bad Bar::pong"

try:
  s = f.pong()
  if s != "Bar::pong();Foo::pong();Bar::ping();":
    raise RuntimeError
  pass
except:
  raise RuntimeError," bad Foo::pong"
  
try:
  s = fb.pong()
  if s != "Bar::pong();Foo::pong();FooBar::ping();":
    raise RuntimeError
  pass
except:
  raise RuntimeError," bad FooBar::pong"

protected=1  
try:
  b.ping()
  protected=0
except:
  pass
if not protected:
  raise  RuntimeError,"Boo::ping is protected"
  
protected=1  
try:
  f.ping()
  protected=0
except:
  pass
if not protected:
  raise  RuntimeError,"Foo::ping is protected"


protected=1  
try:
  f.pang()
  protected=0
except:
  pass
if not protected:
  raise  RuntimeError,"FooBar::pang is protected"
