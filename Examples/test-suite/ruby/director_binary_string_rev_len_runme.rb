#!/usr/bin/env ruby
#
# Put description here
#

require 'swig_assert'

require 'director_binary_string_rev_len'

class DirectorBinaryStringCallback < Director_binary_string_rev_len::Callback
  def run(dataBufferAA)
    ret = 0
    unless dataBufferAA.nil?
        dataBufferAA.each_char do |c|
            ret += c.ord * 2
        end
    end
    return ret
  end
end

# Keep a reference to the director object in a local variable so that Ruby's GC
# does not collect it while the C++ Caller still holds a (non-owning) pointer to
# it - see the sibling director_binary_string test which does the same.
callback = DirectorBinaryStringCallback.new
caller = Director_binary_string_rev_len::Caller.new(callback)
sum = caller.call()

raise RuntimeError if sum != 9*2*8
