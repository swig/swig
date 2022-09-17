package main

import . "swigtests/typemap_out_optimal"

func main() {
	SetXXTrace(false)
	_ = XXCreate()
	_ = XXCreateConst()
}
