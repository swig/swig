#!/usr/bin/env ruby
#
# A simple function to create useful asserts
#
# Author::    gga
# Copyright:: 2007
# License::   Ruby
#


#
# Exception raised when some swig binding test fails
#
class SwigRubyError < RuntimeError
end


#
# Asserts whether a and b are equal.
#
# scope - optional Binding where to run the code
# msg   - optional additional message to print
#
def swig_assert_equal( a, b, scope = nil, msg = nil )
  begin
    check = "#{a} == #{b}"
    if scope.kind_of? Binding
      ok = eval(check.to_s, scope)
    else
      ok = eval(check.to_s)
      msg = scope if !msg
    end
  rescue => e
    raise
  end

  unless ok
    raise SwigRubyError.new("FAILED CHECK: #{check} was #{eval(a)} #{msg}")
  end

  if $VERBOSE
    $stdout.puts "\tPASSED #{check} #{msg}"
  end

  return ok
rescue => e
  trace = e.backtrace[1..-1]
  $stderr.puts "#{trace[0,1]}: #{e}"
  if trace.size > 1
    $stderr.puts "\tfrom #{trace[1..-1].join("\n\t     ")}"
  end
  exit(1)
end


#
# Asserts whether an expression runs properly
#
# scope - optional Binding where to run the code
# msg   - optional additional message to print
#
def swig_assert( expr, scope = nil, msg = nil )
  begin
    if scope.kind_of? Binding
      eval(expr.to_s, scope)
    else
      eval(expr.to_s)
      msg = scope if !msg
    end
  rescue => e
    raise SwigRubyError.new("Wrong assert: #{expr.to_s} - #{e}")
  end
  if $VERBOSE
    $stdout.puts "\tPASSED #{expr} #{msg}"
  end
rescue => e
  trace = e.backtrace[1..-1]
  $stderr.puts "#{trace[0,1]}: #{e}"
  if trace.size > 1
    $stderr.puts "\tfrom #{trace[1..-1].join("\n\t     ")}"
  end
  exit(1)
end


#
# Given a set of lines as text, runs each of them, asserting them.
# Lines that are of the form:
#     a == b  are run with swig_assert_equal
#             others are run with swig_assert.
#
# scope - optional Binding where to run the code
# msg   - optional additional message to print
#
def swig_assert_each_line( lines, scope = nil, msg = nil )
  lines.split("\n").each do |line|
    next if line.empty? or line =~ /^\s*#.*/
      if line =~ /(.*)\s*==\s*(.*)/
        swig_assert_equal($1, $2, scope, msg)
      else
        swig_assert(line, scope, msg)
      end
  end
end
