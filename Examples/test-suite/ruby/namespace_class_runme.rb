#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Python counterpart.
#

require 'swig_assert'
require 'namespace_class'

begin
  p = Namespace_class::Private1.new
  raise SwigRubyError.new("Private1 is private")
rescue NameError => e
  # OK
end

begin
  p = Namespace_class::Private2.new
  raise SwigRubyError.new("Private2 is private")
rescue NameError => e
  # OK
end

Namespace_class::EulerT3D.toFrame(1, 1, 1)

b = Namespace_class::BooT_i.new
b = Namespace_class::BooT_H.new


f = Namespace_class::FooT_i.new
f.quack(1)

f = Namespace_class::FooT_d.new
f.moo(1)

f = Namespace_class::FooT_H.new
f.foo(Namespace_class::Hi)

f_type = f.class.to_s
swig_assert_equal('f_type', '"Namespace_class::FooT_H"', binding)

