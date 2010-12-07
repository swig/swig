# Operator overloading example

catch { load ./example[info sharedlibextension] example}

set a [Complex -args 2 3]
set b [Complex -args -5 10]

puts "a   = $a [$a str]"
puts "b   = $b [$b str]"

set c [$a + $b]
Complex -this $c
puts "c   = $c [$c str]"

set d [$a * $b]
Complex -this $d
puts "a*b  = [$d str]"

# Alternative calling convention
set e [Complex_- $a $c]
puts "a-c  = [Complex_str $e]"

set f [new_ComplexCopy $e]
Complex -this $f
puts "f    = [$f str]"

# Call assignment operator
$c = $f
puts "c    = [$c str]"

