package main

import "swigtests/cpp11_decltype"

func main() {
    if cpp11_decltype.BShould_be_string != "xyzzy" {
        panic("BShould_be_string mismatch")
    }

    if cpp11_decltype.BPlain_string != "hello" {
        panic("BPlain_string mismatch")
    }
}
