require 'director_exception'

include Director_exception

class MyFoo < Foo
  def ping
    raise NotImplementedError, "MyFoo::ping() EXCEPTION"
  end
end

class MyFoo2 < Foo
  def ping
    nil # error: should return a string
  end
end

ok = false

a = MyFoo.new
b = launder(a)

begin
  b.pong
rescue NotImplementedError
  ok = true
end

raise RuntimeError unless ok

ok = false

a = MyFoo2.new
b = launder(a)

begin
  b.pong
rescue TypeError
  ok = true
end

raise RuntimeError unless ok

