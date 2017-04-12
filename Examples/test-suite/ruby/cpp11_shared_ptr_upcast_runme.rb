require 'swig_assert'
require 'cpp11_shared_ptr_upcast'


include Cpp11_shared_ptr_upcast

# non-overloaded
simple_assert_equal( 7, derived_num1(Derived.new(7)) )
simple_assert_equal( 7, derived_num2([Derived.new(7)]) )
simple_assert_equal( 7, derived_num3({0 => Derived.new(7)}) )

simple_assert_equal(-1, base_num1(Derived.new(7)) )
simple_assert_equal(-1, base_num2([Derived.new(7)]) )
simple_assert_equal(-1, base_num3({0 => Derived.new(7)}) )

simple_assert_equal( 999, derived_num1(nil) )
simple_assert_equal( 999, derived_num2([nil]) )
simple_assert_equal( 999, derived_num3({0 => nil}) )

simple_assert_equal( 999, base_num1(nil) )
simple_assert_equal( 999, base_num2([nil]) )
simple_assert_equal( 999, base_num3({0 => nil}) )

# overloaded
simple_assert_equal( 7, derived_num(Derived.new(7)) )
simple_assert_equal( 7, derived_num([Derived.new(7)]) )
simple_assert_equal( 7, derived_num({0 => Derived.new(7)}) )

simple_assert_equal(-1, base_num(Derived.new(7)) )
simple_assert_equal(-1, base_num([Derived.new(7)]) )
simple_assert_equal(-1, base_num({0 => Derived.new(7)}) )

# ptr to shared_ptr
simple_assert_equal( 7, derived2_num1(Derived2.new(7)) )
simple_assert_equal( 7, derived2_num2([Derived2.new(7)]) )
simple_assert_equal( 7, derived2_num3({0 => Derived2.new(7)}) )

simple_assert_equal( -1, base2_num1(Derived2.new(7)) )

begin
    # Upcast for pointers to shared_ptr in this generic framework has not been implemented
    simple_assert_equal( -1, base2_num2([Derived2.new(7)]) )
    raise RuntimeError, "Failed to catch TypeError"
rescue TypeError
end
begin
    # Upcast for pointers to shared_ptr in this generic framework has not been implemented
    simple_assert_equal( -1, base2_num3({0 => Derived2.new(7)}) )
    raise RuntimeError, "Failed to catch TypeError"
rescue TypeError
end

simple_assert_equal( 888, derived2_num1(nil) )
simple_assert_equal( 999, derived2_num2([nil]) ) # although 888 would be more consistent
simple_assert_equal( 999, derived2_num3({0 => nil}) ) # although 888 would be more consistent

simple_assert_equal( 888, base2_num1(nil) )
simple_assert_equal( 999, base2_num2([nil]) ) # although 888 would be more consistent
simple_assert_equal( 999, base2_num3({0 => nil}) ) # although 888 would be more consistent

