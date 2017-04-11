require 'cpp11_shared_ptr_director'

include Cpp11_shared_ptr_director

class Derived < Base

  def initialize(flag)
    @return_none = flag
    super()
  end

  def ret_c_shared_ptr
    if @return_none
      nil
    else
      C.new
    end
  end

  def ret_c_by_value
    C.new
  end

  def take_c_by_value(c)
    c.get_m
  end

  def take_c_shared_ptr_by_value(c)
    c.get_m
  end

  def take_c_shared_ptr_by_ref(c)
    c.get_m
  end

end

a = Derived.new(false)
b = Derived.new(true)

raise unless call_ret_c_shared_ptr(a) ==  1
raise unless call_ret_c_shared_ptr(b) == -1
raise unless call_ret_c_by_value(a)   ==  1

raise unless call_take_c_by_value(a)            == 5
raise unless call_take_c_shared_ptr_by_value(a) == 6
raise unless call_take_c_shared_ptr_by_ref(a)   == 7

