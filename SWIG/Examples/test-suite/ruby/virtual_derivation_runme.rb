require 'virtual_derivation'

b = Virtual_derivation::B.new 3

if b.get_a() != b.get_b() 
  print "something is really wrong ", b.get_a(), "\n"
  raise RuntimeError 
end
