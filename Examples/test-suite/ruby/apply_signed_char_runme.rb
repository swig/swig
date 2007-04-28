#!/usr/bin/env ruby
#
# Put script description here.
#
# Author::    gga
# Copyright:: 2007
# License::   Ruby
#

require 'swig_assert'
require 'apply_signed_char'

include Apply_signed_char


['CharValFunction', 'CCharValFunction', 'CCharRefFunction'].each do |m|
  [ 3, -3 ].each do |v|
    val = send( m, v )
    swig_assert( v == val, "for #{m} #{val} == #{v} ")
  end
end

{ 'globalchar' => -109,
  'globalconstchar' => -110,
}.each do |k,v|
  val = Apply_signed_char.send( k )
  swig_assert( v == val, "for #{k} #{val} == #{v} ")
end


a = DirectorTest.new

['CharValFunction', 'CCharValFunction', 'CCharRefFunction'].each do |m|
  [ 3, -3 ].each do |v|
    val = a.send( m, v )
    swig_assert( v == val, "for DirectorTest.#{m} #{val} == #{v} ")
  end
end

{ 'memberchar' => -111,
  'memberconstchar' => -112,
}.each do |k,v|
  val = a.send( k )
  swig_assert( v == val, "for #{k} #{val} == #{v} ")
end
