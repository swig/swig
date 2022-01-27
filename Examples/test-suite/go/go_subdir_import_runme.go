package main

import (
	"swigtests/go_subdir_import_a"
	"swigtests/testdir/go_subdir_import/go_subdir_import_b"
	"swigtests/testdir/go_subdir_import/go_subdir_import_c"
)

func main() {
	b := go_subdir_import_b.NewObjB();
	c := go_subdir_import_c.NewObjC();
	v := go_subdir_import_a.AddFive(b, c)
	if v != 50 {
		panic(0)
	}
}
