# file: runme.rb

require 'example'

# Try to set the values of some global variables

Example.ivar   =  42
Example.svar   = -31000
Example.lvar   =  65537
Example.uivar  =  123456
Example.usvar  =  61000
Example.ulvar  =  654321
Example.scvar  =  -13
Example.ucvar  =  251
Example.cvar   =  "S"
Example.fvar   =  3.14159
Example.dvar   =  2.1828
Example.strvar =  "Hello World"
Example.cstrvar = "Goodbye"
Example.iptrvar= Example.new_int(37)
Example.ptptr  = Example.new_Point(37,42)
Example.name   = "Bill"

# Now print out the values of the variables

puts "Variables (values printed from Ruby)"

print "ivar      = ", Example.ivar, "\n"
print "svar      = ", Example.svar, "\n"
print "lvar      = ", Example.lvar, "\n"
print "uivar     = ", Example.uivar, "\n"
print "usvar     = ", Example.usvar, "\n"
print "ulvar     = ", Example.ulvar, "\n"
print "scvar     = ", Example.scvar, "\n"
print "ucvar     = ", Example.ucvar, "\n"
print "fvar      = ", Example.fvar, "\n"
print "dvar      = ", Example.dvar, "\n"
print "cvar      = ", Example.cvar, "\n"
print "strvar    = ", Example.strvar, "\n"
print "cstrvar   = ", Example.cstrvar, "\n"
print "iptrvar   = ", Example.iptrvar, "\n"
print "name      = ", Example.name, "\n"
print "ptptr     = ", Example.ptptr, " ", Example.Point_print(Example.ptptr), "\n"
print "pt        = ", Example.pt, " ", Example.Point_print(Example.pt), "\n"

puts "\nVariables (values printed from C)"

Example.print_vars()

puts "\nNow I'm going to try and modify some read only variables";

puts "     Tring to set 'path'";
begin
  Example.path = "Whoa!"
  puts "Hey, what's going on?!?! This shouldn't work"
rescue
  puts "Good."
end

puts "     Trying to set 'status'";
begin
  Example.status = 0
  puts "Hey, what's going on?!?! This shouldn't work"
rescue
  puts "Good."
end


print "\nI'm going to try and update a structure variable.\n\n"

Example.pt = Example.ptptr

puts "The new value is"
Example.pt_print()
print "You should see the value ", Example.Point_print(Example.ptptr), "\n"



