#!/usr/bin/env ruby
#
# Tests the bounds checking for integral parameters passed to wrapped functions.
#

require 'swig_assert'
require 'numeric_bounds_checking'

limits = Numeric_bounds_checking::Limits.new
checker = Numeric_bounds_checking::Checker.new

all_ok = true

types = %w(schar uchar
           shrt  ushrt
           int   uint
           long  ulong)
types += %w(llong ullong) if limits.respond_to?(:llong_min)

types.each do |t|
  min = limits.send("#{t}_min")
  max = limits.send("#{t}_max")

  meth = "pass_#{t}"

  # check within bounds
  swig_assert_equal("checker.#{meth}(#{min})", "#{min}", binding)
  swig_assert_equal("checker.#{meth}(#{max})", "#{max}", binding)

  # check outside bounds
  [ min - 1, max + 1 ].each do |val|
    ok = false
    begin
      ret = checker.send("#{meth}", val)
    rescue RangeError, TypeError
      ok = true
    end
    $stderr.puts "\n#{meth}(#{val}): Expected exception but got #{ret} for #{val} (type '#{t}')  " unless ok
    all_ok = all_ok && ok
  end
  raise SwigRubyError.new("\nAt least one bounds check failed  ") unless all_ok
end
