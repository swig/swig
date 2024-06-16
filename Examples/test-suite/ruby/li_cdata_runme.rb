#!/usr/bin/env ruby
#
# Put description here
#

require 'swig_assert'
require 'li_cdata'

include Li_cdata


s = "ABC\0abc"
m = malloc(256)
memmove(m, s)
ss = cdata(m, 7)
swig_assert(ss == "ABC\0abc", binding, "failed");
