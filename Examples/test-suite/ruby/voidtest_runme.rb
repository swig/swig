#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'voidtest'

Voidtest.globalfunc()
f = Voidtest::Foo.new
f.memberfunc()

Voidtest::Foo.staticmemberfunc()

v1 = Voidtest::vfunc1(f)
v3 =  Voidtest::vfunc3(v1)

v3.memberfunc()

