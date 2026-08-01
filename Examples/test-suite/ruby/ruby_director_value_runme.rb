#!/usr/bin/env ruby
#
# Check that a VALUE director method argument, passed either by value or as a
# const reference, arrives in Ruby as the object itself rather than as a proxy.
#

require 'swig_assert'

require 'ruby_director_value'

class MyCallback < Ruby_director_value::Callback
  attr_reader :received
  def callback(param1)
    @received = param1
  end
  def callback_ref(param1)
    @received = param1
  end
end

handler = MyCallback.new
obj = "test data"

Ruby_director_value.call_callback(handler, obj)
if not handler.received.equal?(obj)
  raise RuntimeError, "callback did not receive the object itself, got #{handler.received.inspect}"
end

Ruby_director_value.call_callback_ref(handler, obj)
if not handler.received.equal?(obj)
  raise RuntimeError, "callback_ref did not receive the object itself, got #{handler.received.inspect}"
end
