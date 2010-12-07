#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'swig_assert'

require 'li_std_vector'

include Li_std_vector

iv = IntVector.new(4)

swig_assert( "iv.respond_to? :each", binding )

begin
  iv.each
  swig_assert( false, nil, "iv.each worked with no block!")
rescue ArgumentError
end

swig_assert_each_line(<<'EOF', binding)
iv.respond_to?(:each) == true
iv.respond_to?(:each_with_index) == true
EOF

iv.each_with_index { |e,i| 
  swig_assert("#{e} == 0", binding, "for iv[#{i}] == 0") 
}

0.upto(3) { |i| iv[i] = i }

{ "iv[-1]" => 3,
  "iv.slice(0,2).to_s" => "01", 
  "iv.slice(1,2).to_s" => "12", 
  "iv[0,-2]" => nil,
  "iv[0,3].to_s" => "012",
  "iv[0,10].to_s" => "012",
  "iv[1..2].to_s" => '12',
  "iv[1..3].to_s" => '123',
  "iv[1..4].to_s" => '123',
  "iv[1..-2].to_s" => '12',
  "iv[2..-3]" => nil,
}.each do |k,v|
  swig_assert( "#{k} == #{v.inspect}", binding )
end

swig_assert_each_line(<<'EOF', binding)
iv << 5
iv.push 5
iv.pop == 5
iv.unshift(7)
iv.shift == 7
iv.unshift(7, 3)
iv.insert(1,5)
iv.insert(0, 3)
iv.unshift(2,3,4)
x = average(iv)
y = average([1, 2, 3, 4])
half([10, 10.5, 11, 11.5])
EOF

dv = DoubleVector.new(10)

swig_assert( "dv.respond_to? :each_with_index", binding )

dv.each_with_index { |e,i| swig_assert_equal("dv[#{i}]", 0.0, binding) }

0.upto(9) { |i| dv[i] = i/2.0 }

{ "dv[-1]" => 4.5,
  "dv.slice(0,2).to_s" => "0.00.5",
  "dv[0,-2]" => nil,
  "dv[0,3].to_s" => "0.00.51.0",
  "dv[3,3].to_s" => "1.52.02.5",
}.each do |k,v|
  swig_assert_equal( k, v.inspect, binding )
end

swig_assert_each_line(<<'EOF', binding)
dv.delete_at(2)
dv.delete_if { |x| x == 2.0 }
dv.include? 3.0
dv.find {|x| x == 3.0 }
dv.kind_of? DoubleVector
halved = []
halved = dv.map { |x| x / 2 }
halve_in_place(dv)
halved.to_a == dv.to_a
sv = StructVector.new
sv << Li_std_vector::Struct.new
sv[0].class == Li_std_vector::Struct
sv[1] = Li_std_vector::Struct.new

EOF

bv = BoolVector.new(2)
[true, false, true, true].each { |i| bv.push(i) }
0.upto(bv.size-1) { |i| bv[i] = !bv[i] }
bv_check = [true, true, false, true, false, false]
for i in 0..bv.size-1 do
  swig_assert(bv_check[i] == bv[i], binding, "bv[#{i}]")
end

swig_assert_each_line(<<'EOF', binding)
lv = LanguageVector.new
lv << 1
lv << [1,2]
lv << 'asd'
lv[0], lv[1] = lv[1], lv[0]
EOF


# this should assert
begin
  lv = LanguageVector.new('crapola')
rescue
end
