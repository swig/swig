#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Java counterpart.
#

require 'swig_assert'
require 'template_nested_flat'

Template_nested_flat::T_NormalTemplateNormalClass.new.tmethod(Template_nested_flat::NormalClass.new)
Template_nested_flat::OuterClass.new.T_OuterTMethodNormalClass(Template_nested_flat::NormalClass.new)

tf = Template_nested_flat::TemplateFuncs.new
swig_assert_equal("tf.T_TemplateFuncs1Int(-10)", "-10", binding)
swig_assert_equal("tf.T_TemplateFuncs2Double(-12.3)", "-12.3", binding)

tn = Template_nested_flat::T_NestedOuterTemplateDouble.new
swig_assert_equal("tn.hohum(-12.3)", "-12.3", binding)

inner1 = Template_nested_flat::OuterClass.new.useInner1(Template_nested_flat::T_OuterClassInner1Int.new)
inner2 = Template_nested_flat::T_OuterClassInner2NormalClass.new
inner2.embeddedVar = 2
inner22 = Template_nested_flat::OuterClass.new.useInner2Again(inner2)
inner3 = Template_nested_flat::T_OuterClassInner1Double.new
