require 'lib_std_string'

include Lib_std_string

# Checking expected use of %typemap(in) std::string {}
test_value_in("Fee")

# Checking expected result of %typemap(out) std::string {}
raise RuntimeError unless test_value_in("Fi") == "Fi"

# Verify type-checking for %typemap(in) std::string {}
exceptionRaised = false
begin
  test_value_in(0)
rescue TypeError
  exceptionRaised = true
ensure
  raise RuntimeError unless exceptionRaised
end

# Checking expected use of %typemap(in) const std::string & {}
test_const_reference_in("Fo")

# Verify type-checking for %typemap(in) const std::string & {}
exceptionRaised = false
begin
  test_const_reference_in(0)
rescue TypeError
  exceptionRaised = true
ensure
  raise RuntimeError unless exceptionRaised
end

