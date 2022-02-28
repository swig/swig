#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Python counterpart.
#

require 'swig_assert'
require 'cpp_enum'

f = Cpp_enum::Foo.new
swig_assert_equal('f.hola', 'Cpp_enum::Foo::Hello', binding)

f.hola = Cpp_enum::Foo::Hi
swig_assert_equal('f.hola', 'Cpp_enum::Foo::Hi', binding)

f.hola = Cpp_enum::Foo::Hello
swig_assert_equal('f.hola', 'Cpp_enum::Foo::Hello', binding)

Cpp_enum::hi = Cpp_enum::Hello
swig_assert_equal('Cpp_enum::hi', 'Cpp_enum::Hello', binding)
