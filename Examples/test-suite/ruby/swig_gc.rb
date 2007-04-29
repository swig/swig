#!/usr/bin/env ruby
#
# Put script description here.
#
# Author::    
# Copyright:: 
# License::   Ruby
#

#
# VERY nice function from Robert Klemme to check memory leaks
# and check on what GC has collected since last call.
#
module GC
  @@last_stat = nil
  def self.stats(klass = nil)
    return unless $VERBOSE

    stats = Hash.new(0)
    ObjectSpace.each_object {|o| stats[o.class] += 1}

    if klass
      v = stats[klass]
      printf "\t%-30s  %10d", klass.to_s, v
      printf " | delta %10d", (v - @@last_stat[klass]) if @@last_stat
      puts
    else
      stats.sort {|(k1,v1),(k2,v2)| v2 <=> v1}.each do |k,v|
        printf "\t%-30s  %10d", k, v
        printf " | delta %10d", (v - @@last_stat[k]) if @@last_stat
        puts
      end
    end
    
    @@last_stat = stats
  end
end
