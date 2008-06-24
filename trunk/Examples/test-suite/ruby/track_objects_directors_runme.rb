#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'swig_assert'

require 'track_objects_directors'
	
class MyFoo < Track_objects_directors::Foo
  def ping
    "MyFoo::ping()"
  end
end

a = MyFoo.new

raise RuntimeError if a.ping != "MyFoo::ping()"
raise RuntimeError if a.pong != "Foo::pong();MyFoo::ping()"

b = Track_objects_directors::Foo.new

raise RuntimeError if b.ping != "Foo::ping()"
raise RuntimeError if b.pong != "Foo::pong();Foo::ping()"

container = Track_objects_directors::Container.new
foo = MyFoo.new
container.set_foo(foo)
    
myFoo1 = container.get_foo
myFoo2 = container.get_foo

if not myFoo1.equal?(myFoo2)
  raise RuntimeError, "MyFoo's should be the same"
end
