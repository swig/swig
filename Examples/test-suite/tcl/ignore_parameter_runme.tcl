if [ catch { load ./ignore_parameter[info sharedlibextension] Ignore_parameter} err ] {
    puts stderr "Could not load shared object:\n$err"
    exit 1
}

proc check {got expected} {
    if {$got != $expected} { error "'$got' != '$expected'" }
}

check [jaguar 200 0] "hello"
check [lotus "foo" 1] 101
check [tvr "bar" 2] 8.8
check [ferrari] 101
check $called_argout 1
check $called_freearg 1
check [fiat 17] 17

SportsCars car
check [car daimler 200 0] "hello"
check [car astonmartin "foo" 1] 101
check [car bugatti "bar" 2] 8.8
check [car lamborghini] 101
check [car maseratti 289] 289
check [car audi] 8.8

MiniCooper mini 200 0
MorrisMinor morris "baz" 0
FordAnglia anglia "quux" 200
AustinAllegro allegro
