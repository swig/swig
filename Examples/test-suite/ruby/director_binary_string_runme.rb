#!/usr/bin/env ruby
#
# Put description here
#

require 'swig_assert'

require 'director_binary_string'

class DirectorBinaryStringCallback < Director_binary_string::Callback
  def run(dataBufferAA, dataBufferBB)
    ret = 0
    unless dataBufferAA.nil?
        dataBufferAA.each_char do |c|
            ret += c.ord * 2
        end
    end
    unless dataBufferBB.nil?
        dataBufferBB.each_char do |c|
            ret += c.ord * 3
        end
    end
    return ret
  end
  def writeData(dataBufferAA)
    ret = 0
    unless dataBufferAA.nil?
        dataBufferAA.each_char do |c|
            ret += c.ord * 2
        end
    end
    return ret
  end
end

caller = Director_binary_string::Caller.new
callback = DirectorBinaryStringCallback.new
caller.setCallback(callback)
sum = caller.call()
sumData = caller.callWriteData()
caller.delCallback()

raise RuntimeError if sum != 9*2*8 + 13*3*5
raise RuntimeError if sumData != 9*2*8

# FIXME accessing abstract class or protected constructor
# It does make sense as writeData() is abstract
# Director_binary_string::Callback.new.run(nil, nil)
callback = DirectorBinaryStringCallback.new
caller.setCallback(callback)
caller.call_null()
caller.delCallback()
