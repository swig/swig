#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Python counterpart.
#

require 'swig_assert'
require 'nested_template_base'

ois = Nested_template_base::InnerS.new(123)
oic = Nested_template_base::InnerC.new

# Check base method is available
swig_assert_equal('oic.outer(ois).val', '123', binding, 'Wrong value calling outer')

# Check non-derived class using base class
swig_assert_equal('oic.innerc().outer(ois).val', '123', binding, 'Wrong value calling innerc')
