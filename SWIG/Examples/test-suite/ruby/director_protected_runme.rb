require 'director_protected'

class FooBar < Director_protected::Bar
  def ping
    "FooBar::ping();"
  end
end

b = Director_protected::Bar.new
fb = FooBar.new

raise RuntimeError if b.pong != "Bar::pong();Foo::pong();Bar::ping();"
raise RuntimeError if fb.pong != "Bar::pong();Foo::pong();FooBar::ping();"
