#!/usr/bin/env ruby

require 'li_constraints'
include Li_constraints

def check_double(except, fn, f, val)
  actual = true
  proper = false
  begin
    fn.call(val)
  rescue => e
    actual = false
    proper = e.class == ArgumentError && e.message == "Expected a #{f} value."
  end
  if actual
    if !except
      raise RuntimeError, "function '#{f}' with #{val} should perform an exception"
    end
  else
    if except
      raise RuntimeError, "function '#{f}' with #{val} should not perform an exception"
    elsif !proper
      raise RuntimeError, "function '#{f}' with #{val} should perform a proper exception"
    end
  end
end

nonnegative = -> (v) { test_nonnegative(v) }
check_double(true, nonnegative, "non-negative", 10)
check_double(true, nonnegative, "non-negative", 0)
check_double(false, nonnegative, "non-negative", -10)

nonpositive = -> (v) { test_nonpositive(v) }
check_double(false, nonpositive, "non-positive", 10)
check_double(true, nonpositive, "non-positive", 0)
check_double(true, nonpositive, "non-positive", -10)

positive = -> (v) { test_positive(v) }
check_double(true, positive, "positive", 10)
check_double(false, positive, "positive", 0)
check_double(false, positive, "positive", -10)

negative = -> (v) { test_negative(v) }
check_double(false, negative, "negative", 10)
check_double(false, negative, "negative", 0)
check_double(true, negative, "negative", -10)

nonzero = -> (v) { test_nonzero(v) }
check_double(true, nonzero, "nonzero", 10)
check_double(false, nonzero, "nonzero", 0)
check_double(true, nonzero, "nonzero", -10)

have_exception = false
begin
  test_nonnull(nil)
rescue => e
  have_exception = e.class == NullReferenceError && e.message == "Received a NULL pointer."
end
if not have_exception
  raise RuntimeError, "test_nonnull should perform exception with 'null' value"
end
nonnull = get_nonnull()
test_nonnull(nonnull)
