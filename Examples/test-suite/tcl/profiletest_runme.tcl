catch { load ./profiletest.so profiletest}
catch { load ./profiletest.dll profiletest}    ;# Windows

set  a [new_A]
set  b [new_B]

for {set i 0} {$i < 1000000} {incr i 1} {
    set a [B_fn $b $a]
}