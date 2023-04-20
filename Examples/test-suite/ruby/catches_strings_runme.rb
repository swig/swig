#!/usr/bin/env ruby

require 'swig_assert'

require 'catches_strings'

exception_thrown = false
begin
  Catches_strings::StringsThrower.charstring()
rescue RuntimeError => e
  if (!e.to_s.include? "charstring message")
    raise RuntimeError, "incorrect exception message: #{e.to_s}"
  end
  exception_thrown = true
end
if (!exception_thrown)
  raise RuntimeError, "Should have thrown an exception"
end

exception_thrown = false
begin
  Catches_strings::StringsThrower.stdstring()
rescue RuntimeError => e
  if (!e.to_s.include? "stdstring message")
    raise RuntimeError, "incorrect exception message: #{e.to_s}"
  end
  exception_thrown = true
end
if (!exception_thrown)
  raise RuntimeError, "Should have thrown an exception"
end
