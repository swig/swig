#!/usr/bin/env ruby
#
# Verify that wrapped objects use Ruby's embedded TypedData slot on Ruby 3.3+.
#

require 'swig_assert'
require 'ruby_typeddata_embedded'

include Ruby_typeddata_embedded

thing = Thing.new(42)
swig_assert_equal(42, thing.value, binding)

# From Ruby 3.3 the per-class descriptor enables RUBY_TYPED_EMBEDDABLE, so the
# wrapper is embedded in the object slot. Without it the wrapper is malloc'd and
# leaked, since the free callback no longer releases it.
if RUBY_VERSION >= "3.3"
  swig_assert(swig_wrapper_embedded(thing), binding, "wrapper should be embedded on Ruby >= 3.3")
end
