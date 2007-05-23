#!/usr/bin/env ruby
#
# This is a simple speed benchmark suite for std containers,
# to verify their O(n) performance.
# It is not part of the standard tests.
#
# License::   SWIG
#


require 'benchmark'
require 'li_std_speed'
include Li_std_speed


def benchmark(f, phigh, sequences)
  puts f
  print '%10s ' % 'n'
  maxlen = sequences.max { |a,b| a.to_s.size <=> b.to_s.size }
  maxlen = maxlen.to_s.size - 9
  sequences.each { |s| print "%#{maxlen}s" % "#{s.to_s.sub(/.*::/,'')}" }
  puts
  0.upto(phigh-1) do |p|
    n = 2**p
    print "%10d" % n
    for s in sequences
      cont = s.new((0..n).to_a)
      Benchmark.benchmark('',0,"%#{maxlen-1}.6r") { |x|
        x.report { f.call(cont) } 
      }
    end
    puts
  end
end

def iterate(cont)
   it = cont.begin
   last = cont.end
   while it != last 
     it.next
   end
end


def erase(cont)
   it = cont.end
   # can't reuse begin since it might get invalidated
   while it != cont.begin
     it.previous
     # set returns None, so need to reobtain end
     it = cont.erase(it) || cont.end
   end
end

def insert(cont)
  size = cont.size
  size.upto((size<<1) - 1) { |x| cont.push(x) }
end

if $0 == __FILE__
  #GC.disable
  sequences = [RbVector,RbDeque,RbSet,RbList,
               RbFloatVector,RbFloatDeque,RbFloatSet,RbFloatList]
  n = 20
  for f,phigh in [[method(:iterate),n], [method(:insert),n],
                  [method(:erase),n-4]]
    benchmark(f, phigh, sequences)
  end
end

