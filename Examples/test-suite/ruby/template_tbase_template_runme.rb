#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'template_tbase_template'

include Template_tbase_template

a = make_Class_dd()
raise RuntimeError unless a.test() == "test"

