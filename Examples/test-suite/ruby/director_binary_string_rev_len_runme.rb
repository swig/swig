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

caller = Director_binary_string_rev_len::Caller.new(DirectorBinaryStringCallback.new)
sum = caller.call()

raise RuntimeError if sum != 9*2*8
