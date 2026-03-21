package main

import "strconv"
import . "swigtests/li_cdata_bytes_cpp"

func main() {
    m := PredefStr()
    s := Cdata(m, int64(0x200))
    for i := 0; i < 0x100; i++ {
      if int(s[i]) != i {
        panic("Wrong value " + strconv.Itoa(int(s[i])) + " at index " + strconv.Itoa(i))
      }
      if int(s[i + 0x100]) != i {
        panic("Wrong value " + strconv.Itoa(int(s[i])) + " at index " + strconv.Itoa(i + 0x100))
      }
    }
    for i := 0; i < 0x100; i++ {
        v := byte(0x100 - 1 - i)
        s[i] = v
        s[i + 0x100] = v
    }
    m2 := Malloc(0x200)
    Memmove(m2, s)
    if (VerifyBytes(m2) != 0) {
        panic("verifyBytes fails")
    }
    Free(m2)
}
