#!/usr/bin/env ruby
#
# Put description here
#

require 'swig_assert'

require 'director_rev_len_str'

class DirectorBinaryStringCallback < Director_rev_len_str::Callback
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

caller = Director_rev_len_str::Caller.new(DirectorBinaryStringCallback.new)
sum = caller.call()

raise RuntimeError if sum != 9*2*8
