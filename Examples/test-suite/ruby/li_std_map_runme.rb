#!/usr/bin/env ruby
#
# Tests for std::map
#
# 
# 
# 
#

require 'swig_assert'
require 'li_std_map'

swig_assert_each_line(<<'EOF', binding)

a1 = Li_std_map::A.new(3)
a2 = Li_std_map::A.new(7)

p0 = Li_std_map::Pairii.new(1,2)
p1 = Li_std_map::PairA.new(1,a1)
m = {}
m[1] = a1
m[2] = a2

pp1 = Li_std_map::p_identa(p1)
mm = Li_std_map::m_identa(m)

m = Li_std_map::MapA.new
m[1] = a1
m[2] = a2
m.respond_to?(:each_key) == true
m.respond_to?(:each_value) == true

pm ={}
m.each_key { |k| pm[k] = m[k] }
m.each_key { |k| swig_assert_equal("pm[k].object_id", "m[k].object_id", binding, 'only true if %trackings is on') }

m = {}
m[1] = [1,2]
m["foo"] = "hello"

pm = Li_std_map::LanguageMap.new
m.each_key { |k| pm[k] = m[k] }
m.each_key { |k| swig_assert_equal("pm[#{k.inspect}]", "m[#{k.inspect}]", binding) }
EOF


lmap = Li_std_map::LanguageMap.new
lmap[1] = 3
lmap[8] = 9
swig_assert("lmap.select {|k, v| k == 8}.to_s == \"[8, 9]\"", binding)

Li_std_map::populate(Li_std_map.MyMap)
Li_std_map.MyMap["eeeeee"] = 6
swig_assert( "Li_std_map.MyMap['a'] == 1", binding )
swig_assert( "Li_std_map.MyMap['aa'] == 2", binding )
swig_assert( "Li_std_map.MyMap['zzz'] == 3", binding )
swig_assert( "Li_std_map.MyMap['xxxx'] == 4", binding )
swig_assert( "Li_std_map.MyMap['aaaaa'] == 5", binding )
swig_assert( "Li_std_map.MyMap['eeeeee'] == 6", binding )

mii = Li_std_map::IntIntMap.new

mii[1] = 1
mii[1] = 2

swig_assert( "mii[1] == 2", binding )
