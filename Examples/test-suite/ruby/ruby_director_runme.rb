require "swig_assert"
require "ruby_director"

include Ruby_director

class Derived < Base
  def ret_m
    @count ||= 0
    @count += 1
    if @count > 10
      raise
    else
      call_ret_m(self)
    end
  end
end

m = 3
d = Derived.new(m)
call_ret_m(d)
