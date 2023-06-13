#!/usr/bin/env ruby
#
# Put description here
#

require 'swig_assert'
require 'char_binary'

include Char_binary

t = Test.new
str = 'hile'
swig_assert(t.strlen(str) == 4, binding, 'bad multi-arg typemap')
swig_assert(t.ustrlen(str) == 4, binding, 'bad multi-arg typemap')
swig_assert(t.strlen("hil\000") == 4, binding, 'bad multi-arg typemap')
swig_assert(t.ustrlen("hil\000") == 4, binding, 'bad multi-arg typemap')

# creating a raw char*
pc = new_pchar(5)
pchar_setitem(pc, 0, 'h')
pchar_setitem(pc, 1, 'o')
pchar_setitem(pc, 2, 'l')
pchar_setitem(pc, 3, 'a')
pchar_setitem(pc, 4, 0)

swig_assert(t.strlen(pc) == 4, binding, 'bad multi-arg typemap')
swig_assert(t.ustrlen(pc) == 4, binding, 'bad multi-arg typemap')

Char_binary.var_pchar = pc
swig_assert(Char_binary.var_pchar == 'hola', binding, 'bad pointer case')

Char_binary.var_namet = pc
swig_assert(Char_binary.var_namet == 'hola', binding, 'bad pointer case')

delete_pchar(pc)
