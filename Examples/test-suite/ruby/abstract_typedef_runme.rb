require 'abstract_typedef'

include Abstract_typedef

e = Engine.new
a = A.new

raise RuntimeError if a.write(e) != true

