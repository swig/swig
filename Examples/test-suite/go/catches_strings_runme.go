package main

import "strings"
import . "swigtests/catches_strings"

func main() {
  {
    exception_thrown := false
    func() {
      defer func() {
        exception_thrown = strings.Index(recover().(string), "charstring message") == 0
      }()
      StringsThrowerCharstring()
    }()
    if !exception_thrown {
      panic(0)
    }
  }

  {
    exception_thrown := false
    func() {
      defer func() {
        exception_thrown = strings.Index(recover().(string), "stdstring message") == 0
      }()
      StringsThrowerStdstring()
    }()
    if !exception_thrown {
      panic(0)
    }
  }
}
