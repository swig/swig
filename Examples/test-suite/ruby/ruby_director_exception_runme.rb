require "swig_assert"
require "ruby_director_exception"

include Ruby_director_exception

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

d = Derived.new(0)

swig_assert_equal_simple(0, Ruby_director_exception.c_counter)
swig_assert_equal_simple(0, Ruby_director_exception.d_counter)
begin
  call_ret_m(d)
rescue
end
swig_assert_equal_simple(11, Ruby_director_exception.c_counter)
swig_assert_equal_simple(11, Ruby_director_exception.d_counter)
