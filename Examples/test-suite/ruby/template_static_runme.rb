#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Python counterpart.
#

require 'template_static'

Template_static::Foo_i.test
Template_static::Foo_d.test
Template_static::Foo::test
Template_static::Foo::bar_double(1)

