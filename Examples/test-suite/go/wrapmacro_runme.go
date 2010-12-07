package main

import "./wrapmacro"

func main() {
	a := 2
	b := -1
	wrapmacro.Maximum(a, b)
	wrapmacro.Maximum(a/7.0, -b*256)
	wrapmacro.GUINT16_SWAP_LE_BE_CONSTANT(1)
}
