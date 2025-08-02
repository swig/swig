package main

import wrap "swigtests/director_binary_string_rev_len"

type DirectorBinaryStringCallback struct{}

func (p *DirectorBinaryStringCallback) Run(dataBufferAA string) int {
    ret := 0
    for i := 0; i < len(dataBufferAA); i++ {
      ret += int(dataBufferAA[i]) * 2
    }
    return ret
}

func main() {
    callback := wrap.NewDirectorCallback(&DirectorBinaryStringCallback{})
    defer wrap.DeleteDirectorCallback(callback)
    caller := wrap.NewCaller(callback)
    defer wrap.DeleteCaller(caller)
    sum := caller.Call()
    if sum != 9*2*8 {
      panic(sum)
    }
}
