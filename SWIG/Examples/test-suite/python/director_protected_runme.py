from director_protected import *



class FooBar(Bar):
  def ping(self):
    return "FooBar::ping();"


b  = Bar()
f  = b.create()
fb = FooBar()

try:
  s1 = b.pong()
  if s1 != "Bar::pong();Foo::pong();Bar::ping();":
    raise RuntimeError
  pass
except:
  raise RuntimeError, "bad Bar::pong"

try:
  s2 = f.pong()
  if s2 != "Bar::pong();Foo::pong();Bar::ping();":
    raise RuntimeError
  pass
except:
  raise RuntimeError," bad Foo::pong"
  
try:
  s3 = fb.pong()
  if s3 != "Bar::pong();Foo::pong();FooBar::ping();":
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
