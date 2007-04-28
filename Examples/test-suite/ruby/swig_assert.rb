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

def swig_assert( condition, *args )
  raise SwigRubyError.new("FAILED CHECK: #{condition} #{args.join(' ')}") unless eval(condition)
end
