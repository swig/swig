#!/usr/bin/env ruby
#
# Put script description here.
#
# Author::    
# Copyright:: 
# License::   Ruby
#

require 'swig_assert'

require 'li_std_set'
include Li_std_set

swig_assert_each_line(<<'EOF', binding)
s = Set_string.new

s.push("a")
s.push("b")
s << "c"

sum = ''
s.each { |x| sum << x }
sum == 'abc'

b = s.begin  # only if swig iterators are on
e = s.end
sum = ''
while b != e; sum << b.next; end
sum == 'abc'

b = s.rbegin  # only if swig iterators are on
e = s.rend
sum = ''
while b != e; sum << b.next; end
sum == 'cba'


si = Set_int.new
si << 1
si.push(2)
si.push(3)

i = s.begin()
i.next()
s.erase(i)
s.to_s == 'ac'

b = s.begin
e = s.end
e - b == 2

m = b + 1
m.value == 'c'

s = LanguageSet.new
s.insert([1,2])
s.insert(1)
s.insert("hello")
s.to_a == [1,'hello',[1,2]]

EOF

