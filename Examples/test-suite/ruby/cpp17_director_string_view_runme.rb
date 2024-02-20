#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'swig_assert'

require 'cpp17_director_string_view'

class B < Cpp17_director_string_view::A
 attr_accessor :smem

 def initialize(some_string)
  super(some_string)
 end

 def get_first()
  # Since std::string_view contains a pointer into a string, the string
  # cannot be a temporary in order to avoid undefined behaviour.
  @cached_string = super() + " world!"
  return @cached_string
 end

 def process_text(string)
  super(string)
  @smem = "hello"
 end

end


b = B.new("hello")
raise RuntimeError if b.get(0) != "hello"
raise RuntimeError if b.get_first() != "hello world!"
raise RuntimeError if b.call_get_first() != "hello world!"

b.call_process_func()
raise RuntimeError if b.smem != "hello"
