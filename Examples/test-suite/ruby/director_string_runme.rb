#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'swig_assert'

require 'director_string'

class B < Director_string::A
 attr_accessor :smem

 def initialize(some_string)
  super(some_string)
 end

 def get_first()
  return super() + " world!"
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
