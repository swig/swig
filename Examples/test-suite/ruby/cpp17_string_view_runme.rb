#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'swig_assert'

require 'cpp17_string_view'

include Cpp17_string_view

# Checking expected use of %typemap(in) std::string_view {}
test_value("Fee")

# Checking expected result of %typemap(out) std::string_view {}
raise RuntimeError unless test_value("Fi") == "Fi"

# Verify type-checking for %typemap(in) std::string_view {}
exceptionRaised = false
begin
  test_value(0)
rescue TypeError
  exceptionRaised = true
ensure
  raise RuntimeError unless exceptionRaised
end

# Checking expected use of %typemap(in) const std::string_view & {}
test_const_reference("Fo")

# Checking expected result of %typemap(out) const std::string_view& {}
raise RuntimeError unless test_const_reference("Fum") == "Fum"

# Verify type-checking for %typemap(in) const std::string_view & {}
exceptionRaised = false
begin
  test_const_reference(0)
rescue TypeError
  exceptionRaised = true
ensure
  raise RuntimeError unless exceptionRaised
end

#
# Input and output typemaps for pointers and non-const references to
# std::string_view are *not* supported; the following tests confirm
# that none of these cases are slipping through.
#

exceptionRaised = false
begin
  test_pointer("foo")
rescue TypeError
  exceptionRaised = true
ensure
  raise RuntimeError unless exceptionRaised
end

result = test_pointer_out()
raise RuntimeError if result.is_a? String

exceptionRaised = false
begin
  test_const_pointer("bar")
rescue TypeError
  exceptionRaised = true
ensure
  raise RuntimeError unless exceptionRaised
end

result = test_const_pointer_out()
raise RuntimeError if result.is_a? String

result = test_reference_out()
raise RuntimeError if result.is_a? String


# Member Strings
myStructure = Structure.new
if (myStructure.ConstMemberString != "const member string")
  raise RuntimeError 
end


if (Structure.ConstStaticMemberString != "const static member string")
  raise RuntimeError
end


if (stdstringview_empty() != "")
  puts "raise RuntimeError"
end

if (c_empty() != "")
  raise RuntimeError
end


if (c_null() != nil)
  raise RuntimeError
end


if (get_null(c_null()) != nil)
  raise RuntimeError
end


if (get_null(c_empty()) != "non-null")
  raise RuntimeError
end

if (get_null(stdstringview_empty()) != "non-null")
  raise RuntimeError
end
