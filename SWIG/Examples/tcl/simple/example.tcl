#
# Tcl script for testing simple example

# Try to load as a dynamic module.  If not, we'll just assume
# that it was statically linked in.

catch { load ./example.so example}
catch { load ./example.dll example}    ;# Windows

puts [get_time]
set tcl_precision 17
puts "My Variable = $My_variable"
for {set i 0} {$i < 14} {incr i 1} {
    set n [fact $i];
    puts "$i factorial is $n"
}

for {set i 1} {$i < 250} {incr i 1} {
    for {set j 1} {$j < 250} {incr j 1} {
	set n [mod $i $j]
	set My_variable [expr {$My_variable + $n}]
    }
}

puts "My_variable = $My_variable"

