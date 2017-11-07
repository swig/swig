require 'li_boost_shared_ptr_director'

include Li_boost_shared_ptr_director

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

  def take_c_by_ref(c)
    c.get_m
  end

  def take_c_by_pointer(c)
    if c
      c.get_m
    else
      -2
    end
  end

  def take_c_by_pointer_ref(c)
    if c
      c.get_m
    else
      -3
    end
  end

  def take_c_shared_ptr_by_value(c)
    if c
      c.get_m
    else
      -4
    end
  end

  def take_c_shared_ptr_by_ref(c)
    if c
      c.get_m
    else
      -5
    end
  end

  def take_c_shared_ptr_by_pointer(c)
    if c
      c.get_m
    else
      -6
    end
  end

  def take_c_shared_ptr_by_pointer_ref(c)
    if c
      c.get_m
    else
      -7
    end
  end

end

a = Derived.new(false)
b = Derived.new(true)

raise unless call_ret_c_shared_ptr(a) ==  1
raise unless call_ret_c_shared_ptr(b) == -1
raise unless call_ret_c_by_value(a)   ==  1

raise unless call_take_c_by_value(a)                  == 5
raise unless call_take_c_by_ref(a)                    == 6
raise unless call_take_c_by_pointer(a)                == 7
raise unless call_take_c_by_pointer_ref(a)            == 8
raise unless call_take_c_shared_ptr_by_value(a)       == 9
raise unless call_take_c_shared_ptr_by_ref(a)         == 10
raise unless call_take_c_shared_ptr_by_pointer(a)     == 11
raise unless call_take_c_shared_ptr_by_pointer_ref(a) == 12

raise unless call_take_c_by_pointer_with_null(a)                == -2
raise unless call_take_c_by_pointer_ref_with_null(a)            == -3
raise unless call_take_c_shared_ptr_by_value_with_null(a)       == -4
raise unless call_take_c_shared_ptr_by_ref_with_null(a)         == -5
raise unless call_take_c_shared_ptr_by_pointer_with_null(a)     == -6
raise unless call_take_c_shared_ptr_by_pointer_ref_with_null(a) == -7
