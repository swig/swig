# file: example.tcl

catch { load ./example.so example}
catch { load ./example.dll example}    ;# Windows

puts "ICONST = $ICONST (should be 42)"
puts "FCONST = $FCONST (should be 2.1828)"
puts "CCONST = $CCONST (should be 'x')"
puts "SCONST = $SCONST (should be 'Hello World')"
puts "EXPR   = $EXPR (should be 48.5484)"
puts "iconst = $iconst (should be 37)"
puts "fconst = $fconst (should be 3.14)"

if { [catch {
    puts "EXTERN = $EXTERN (Arg! This shouldn't print anything)"
}]} {
    puts "EXTERN isn't defined (good)"
}

if { [catch {
    puts "FOO    = $FOO (Arg! This shouldn't print anything)"
}]} {
    puts "FOO isn't defined (good)"
}

