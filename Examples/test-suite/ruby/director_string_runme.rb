require 'director_string'
require 'test/unit'


include Director_string


class B < A

 def initialize(some_string)
  super(some_string)
 end
end


b = B.new("hello")
b.get_first
b.get(0)