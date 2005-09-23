require 'abstract_signature'

include Abstract_signature

#
# Shouldn't be able to instantiate Abstract_foo, because it declares
# a pure virtual function.
#

exceptionRaised = false
begin
  Abstract_foo.new
rescue NameError
  exceptionRaised = true
rescue TypeError
  # In Ruby 1.8 the exception raised is:
  # TypeError: allocator undefined for Abstract_signature::Abstract_foo
	exceptionRaised = true
ensure
  raise RuntimeError unless exceptionRaised
end

#
# Shouldn't be able to instantiate an Abstract_bar either, because it doesn't
# implement the pure virtual function with the correct signature.
#

exceptionRaised = false
begin
  Abstract_bar.new
rescue NameError
  exceptionRaised = true
rescue TypeError
  # In Ruby 1.8 the exception raised is:
  # TypeError: allocator undefined for Abstract_signature::Abstract_bar
	exceptionRaised = true
ensure
  raise RuntimeError unless exceptionRaised
end

