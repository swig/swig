require 'abstract_inherit'

include Abstract_inherit

#
# Shouldn't be able to instantiate any of these classes
# since none of them implements the pure virtual function
# declared in the base class (Foo).
#

exceptionRaised = false
begin
  Foo.new
rescue NameError
  exceptionRaised = true
ensure
  raise RuntimeError unless exceptionRaised
end

exceptionRaised = false
begin
  Bar.new
rescue NameError
  exceptionRaised = true
ensure
  raise RuntimeError unless exceptionRaised
end

exceptionRaised = false
begin
  Spam.new
rescue NameError
  exceptionRaised = true
ensure
  raise RuntimeError unless exceptionRaised
end

