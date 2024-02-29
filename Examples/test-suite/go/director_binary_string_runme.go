package main

import wrap "swigtests/director_binary_string"

type DirectorBinaryStringCallback struct{}

func (p *DirectorBinaryStringCallback) Run(dataBufferAA string, dataBufferBB string) int {
  ret := 0
  for i := 0; i < len(dataBufferAA); i++ {
    ret += int(dataBufferAA[i]) * 2
  }
  for i := 0; i < len(dataBufferBB); i++ {
    ret += int(dataBufferBB[i]) * 3
  }
  return ret
}

func (p *DirectorBinaryStringCallback) WriteData(data string) int {
  ret := 0
  for i := 0; i < len(data); i++ {
    ret += int(data[i]) * 2
  }
  return ret
}

func main() {
    caller := wrap.NewCaller()
    callback := wrap.NewDirectorCallback(&DirectorBinaryStringCallback{})
    caller.SetCallback(callback)
    sum := caller.Call()
    sumData := caller.CallWriteData()
    caller.DelCallback()

    if sum != 9*2*8 + 13*3*5 {
      panic(sum)
    }

    if sumData != 9*2*8 {
      panic(sumData)
    }

    // FIXME panic: accessing abstract class or protected constructor
    // It does make sense as writeData() is abstract
    // wrap.NewCallback().Run("", "")

    callback = wrap.NewDirectorCallback(&DirectorBinaryStringCallback{})
    caller.SetCallback(callback)
    caller.Call_null()
}
