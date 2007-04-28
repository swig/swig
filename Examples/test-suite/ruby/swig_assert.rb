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


def swig_assert( condition, *args )
  begin
    ok = eval(condition.to_s)
  rescue => e
    raise SwigAssertError.new("Wrong assert: #{condition.to_s} - #{e}")
  end

  unless ok
    raise SwigRubyError.new("FAILED CHECK: #{condition} #{args.join(' ')}")
  end

  if $VERBOSE
    $stdout.puts "\tPASSED #{condition} #{args.join(' ')}"
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
