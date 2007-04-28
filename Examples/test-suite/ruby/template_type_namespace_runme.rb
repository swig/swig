#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'template_type_namespace'

include Template_type_namespace

result = foo()
raise RuntimeError unless result[0].is_a? String

