require 'director_abstract'

class MyFoo < Director_abstract::Foo
  def ping
    "MyFoo::ping()"
  end
end


a = MyFoo.new

if a.ping != "MyFoo::ping()"
  raise RuntimeError, a.ping
end

if a.pong != "Foo::pong();MyFoo::ping()"
  raise RuntimeError, a.pong
end


