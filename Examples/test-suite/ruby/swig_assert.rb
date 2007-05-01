#!/usr/bin/env ruby
#
# A simple function to create useful asserts
#
# Author::    gga
# Copyright:: 2007
# License::   Ruby
#


class SwigRubyError < RuntimeError
end

class SwigAssertError < StandardError
end


def swig_assert_equal( a, b, scope = nil, msg = nil )
  begin
    check = "#{a} == #{b}"
    ok = eval(check, scope)
  rescue => e
    raise SwigAssertError.new("Wrong assert: #{check} - #{e}")
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


def swig_assert( condition, scope = nil, msg = nil )
  begin
    if scope.kind_of? Binding
      eval(condition.to_s, scope)
    else
      eval(condition.to_s)
      msg = scope
    end
  rescue => e
    raise SwigAssertError.new("Wrong assert: #{condition.to_s} - #{e}")
  end
  if $VERBOSE
    $stdout.puts "\tPASSED #{condition} #{msg}"
  end
rescue => e
  trace = e.backtrace[1..-1]
  $stderr.puts "#{trace[0,1]}: #{e}"
  if trace.size > 1
    $stderr.puts "\tfrom #{trace[1..-1].join("\n\t     ")}"
  end
  exit(1)
end


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
