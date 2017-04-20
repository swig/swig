require 'swig_assert'
require 'cpp11_shared_ptr_upcast'


include Cpp11_shared_ptr_upcast

# non-overloaded
swig_assert_equal_simple( 7, derived_num1(Derived.new(7)) )
swig_assert_equal_simple( 7, derived_num2([Derived.new(7)]) )
swig_assert_equal_simple( 7, derived_num3({0 => Derived.new(7)}) )

swig_assert_equal_simple(-1, base_num1(Derived.new(7)) )
swig_assert_equal_simple(-1, base_num2([Derived.new(7)]) )
swig_assert_equal_simple(-1, base_num3({0 => Derived.new(7)}) )

swig_assert_equal_simple( 999, derived_num1(nil) )
swig_assert_equal_simple( 999, derived_num2([nil]) )
swig_assert_equal_simple( 999, derived_num3({0 => nil}) )

swig_assert_equal_simple( 999, base_num1(nil) )
swig_assert_equal_simple( 999, base_num2([nil]) )
swig_assert_equal_simple( 999, base_num3({0 => nil}) )

# overloaded
swig_assert_equal_simple( 7, derived_num(Derived.new(7)) )
swig_assert_equal_simple( 7, derived_num([Derived.new(7)]) )
swig_assert_equal_simple( 7, derived_num({0 => Derived.new(7)}) )

swig_assert_equal_simple(-1, base_num(Derived.new(7)) )
swig_assert_equal_simple(-1, base_num([Derived.new(7)]) )
swig_assert_equal_simple(-1, base_num({0 => Derived.new(7)}) )

# ptr to shared_ptr
swig_assert_equal_simple( 7, derived2_num1(Derived2.new(7)) )
swig_assert_equal_simple( 7, derived2_num2([Derived2.new(7)]) )
swig_assert_equal_simple( 7, derived2_num3({0 => Derived2.new(7)}) )

swig_assert_equal_simple( -1, base2_num1(Derived2.new(7)) )

begin
    # Upcast for pointers to shared_ptr in this generic framework has not been implemented
    swig_assert_equal_simple( -1, base2_num2([Derived2.new(7)]) )
    raise RuntimeError, "Failed to catch TypeError"
rescue TypeError
end
begin
    # Upcast for pointers to shared_ptr in this generic framework has not been implemented
    swig_assert_equal_simple( -1, base2_num3({0 => Derived2.new(7)}) )
    raise RuntimeError, "Failed to catch TypeError"
rescue TypeError
end

swig_assert_equal_simple( 888, derived2_num1(nil) )
swig_assert_equal_simple( 999, derived2_num2([nil]) ) # although 888 would be more consistent
swig_assert_equal_simple( 999, derived2_num3({0 => nil}) ) # although 888 would be more consistent

swig_assert_equal_simple( 888, base2_num1(nil) )
swig_assert_equal_simple( 999, base2_num2([nil]) ) # although 888 would be more consistent
swig_assert_equal_simple( 999, base2_num3({0 => nil}) ) # although 888 would be more consistent

