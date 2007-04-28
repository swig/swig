#!/usr/bin/env ruby
#
# Ruby's GC is somewhat broken in that it will mark some more stack space
# leading to the collection of local objects to be delayed.
# Thus, upon invokation, it sometimes you can wait up to several
# instructions to kick in.
# See: http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/7449
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'
require 'swig_gc'
require 'newobject2'

include Newobject2

stats = nil
stats = GC.stats(stats, Foo)
100.times { foo1 = makeFoo }
stats = GC.stats(stats, Foo)
swig_assert( 'fooCount == 100', "but is #{fooCount}" )
GC.start
stats = GC.stats(stats, Foo)
swig_assert( 'fooCount <= 1', "but is #{fooCount}" )

