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
  swig_assert( "#{k} == #{v.inspect}", "was #{eval(k).inspect}" )
end


swig_assert( "@iv << 5" )
swig_assert( "@iv.push 5" )
swig_assert( "@iv.pop == 5" )
swig_assert( "@iv.insert(1,5)" )
swig_assert( "@iv.unshift(7)" )
swig_assert( "@iv.shift == 7" )
swig_assert( "@iv.insert(0, 3)" )
swig_assert( "@iv.unshift(7, 3)" )

swig_assert( "x = average(@iv)" )
swig_assert( "y = average([1, 2, 3, 4])" )

swig_assert( "half([10, 10.5, 11, 11.5])" )

@dv = DoubleVector.new(10)

swig_assert( "@dv.respond_to? :each_with_index" )

@dv.each_with_index { |e,i| swig_assert("#{e} == 0.0", "for @dv[#{i}] == 0") }

0.upto(9) { |i| @dv[i] = i/2.0 }

{ "@dv[-1]" => 4.5,
  "@dv.slice(0,2).to_s" => "0.00.5",
  "@dv[0,-2]" => nil,
  "@dv[0,3].to_s" => "0.00.51.0",
  "@dv[3,3].to_s" => "1.52.02.5",
}.each do |k,v|
  swig_assert( "#{k} == #{v.inspect}", "was #{eval(k).inspect}" )
end

swig_assert( "@dv.delete_at(2)" )
swig_assert( "@dv.delete_if() { |x| x == 2.0 }" )

swig_assert( "@dv.include? 3.0" )
swig_assert( "@dv.find {|x| x==3.0 }" )

swig_assert( "halve_in_place(@dv) == nil" )
swig_assert( "@dv = [0.0,0.25,0.75,1.25,1.5,1.75,2.0,2.25]", "#@dv" )

swig_assert( "@sv = StructVector.new" )
swig_assert( "@sv << C_Struct.new" )
