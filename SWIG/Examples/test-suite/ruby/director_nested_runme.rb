require 'director_nested'

class A < Director_nested::FooBar_int
  def do_step
    "A::do_step;"
  end
  
  def get_value
    "A::get_value"
  end
end

a = A.new

raise RuntimeError if a.step != "Bar::step;Foo::advance;Bar::do_advance;A::do_step;"


class B < Director_nested::FooBar_int
  def do_advance
    "B::do_advance;" + do_step
  end

  def do_step
    "B::do_step;"
  end
  
  def get_value
    "B::get_value"
  end
end


b = B.new
raise RuntimeError if b.step != "Bar::step;Foo::advance;B::do_advance;B::do_step;"
