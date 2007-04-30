#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'li_std_vector'

include Li_std_vector

@iv = IntVector.new(4)

swig_assert( "@iv.respond_to? :each" )

begin
  @iv.each
  swig_assert( false, "@iv.each worked with no block!")
rescue ArgumentError
end


@iv.each_with_index { |e,i| swig_assert("#{e} == 0", "for @iv[#{i}] == 0") }

0.upto(3) { |i| @iv[i] = i }

{ "@iv[-1]" => 3,
  "@iv.slice(0,2).to_s" => "01", 
  "@iv.slice(1,2).to_s" => "12", 
  "@iv[0,-2]" => nil,
  "@iv[0,3].to_s" => "012",
  "@iv[0,10].to_s" => "012",
  "@iv[1..2].to_s" => '12',
  "@iv[1..3].to_s" => '123',
  "@iv[1..4].to_s" => '123',
  "@iv[1..-2].to_s" => '12',
  "@iv[2..-3]" => nil,
}.each do |k,v|
  swig_assert( "#{k} == #{v.inspect}" )
end

swig_assert_each_line(<<'EOF')
@iv << 5
@iv.push 5
@iv.pop == 5
@iv.unshift(7)
@iv.shift == 7
@iv.unshift(7, 3)
@iv.insert(1,5)
@iv.insert(0, 3)
x = average(@iv)
y = average([1, 2, 3, 4])
half([10, 10.5, 11, 11.5])
EOF

@dv = DoubleVector.new(10)

swig_assert( "@dv.respond_to? :each_with_index" )

@dv.each_with_index { |e,i| swig_assert("@dv[#{i}] == 0.0") }

0.upto(9) { |i| @dv[i] = i/2.0 }

{ "@dv[-1]" => 4.5,
  "@dv.slice(0,2).to_s" => "0.00.5",
  "@dv[0,-2]" => nil,
  "@dv[0,3].to_s" => "0.00.51.0",
  "@dv[3,3].to_s" => "1.52.02.5",
}.each do |k,v|
  swig_assert( "#{k} == #{v.inspect}" )
end

swig_assert_each_line(<<'EOF')
@dv.delete_at(2)
@dv.delete_if() { |x| x == 2.0 }
@dv.include? 3.0
@dv.find {|x| x==3.0 }
halve_in_place(@dv) == nil
@dv = [0.0,0.25,0.75,1.25,1.5,1.75,2.0,2.25]
@sv = StructVector.new
@sv << Li_std_vector::Struct.new
EOF

