#!/usr/bin/env ruby

require 'benchmark'
require 'li_std_speed'
include Li_std_speed


def benchmark(f, phigh, sequences)
  puts f
  print '%10s ' % 'n' 
  sequences.each { |s| print "%10s" % "#{s.to_s.sub(/.*::/,'')}" }
  puts
  0.upto(phigh-1) do |p|
    n = 2**p
    print "%10d" % n
    for s in sequences
      cont = s.new((0..n).to_a)
      Benchmark.benchmark('',0,'%9.6r') { |x| x.report { f.call(cont) } }
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
   it = cont.end
   size = cont.size
   if cont.kind_of? RbSet
     size.upto((size<<1) - 1) { |x| cont.insert(x) }
   elsif cont.kind_of? RbVector
     cont.reserve(size<<1)
     size.upto((size<<1) - 1) { |x| cont.push(x) }
   else
     size.upto((size<<1) - 1) { |x| cont.push(x) }
   end
end

if $0 == __FILE__
  sequences = [RbVector,RbDeque,RbSet,RbList]
  n = 15
  for f,phigh in [[method(:iterate),n], [method(:insert),n],
                  [method(:erase),n-4]]
    benchmark(f, phigh, sequences)
  end
end
       
