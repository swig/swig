require 'director_protected'

NoProtectedError = Kernel.const_defined?("NoMethodError") ? NoMethodError : NameError

class FooBar < Director_protected::Bar
  protected
    def ping
      "FooBar::ping();"
    end
end

b = Director_protected::Bar.new
fb = FooBar.new

begin 
  fb.ping
rescue NoProtectedError
end

raise RuntimeError if b.pong != "Bar::pong();Foo::pong();Bar::ping();"
raise RuntimeError if fb.pong != "Bar::pong();Foo::pong();FooBar::ping();"
