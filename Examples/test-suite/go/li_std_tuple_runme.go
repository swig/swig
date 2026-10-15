package main

import "swigtests/li_std_tuple"

func main() {
	// Test by-value parameter
	t := li_std_tuple.NewIntDoubleTuple__SWIG_0()
	r := li_std_tuple.Sum_pair_values(t)
	_ = r

	// Test make_int_double
	t2 := li_std_tuple.Make_int_double(10, 20.5)
	_ = t2

	// Test pass_tuples (both by-val and by-const-ref)
	t3 := li_std_tuple.NewIntDoubleTuple__SWIG_0()
	t4 := li_std_tuple.Pass_tuples(t2, t3)
	_ = t4

	// Test with constructed values
	t5 := li_std_tuple.Make_int_double(3, 4.5)
	r2 := li_std_tuple.Sum_pair_values(t5)
	if r2 != 7.5 {
		panic(0)
	}

	// Test pass_tuples with two IntDoubleTuples
	t6 := li_std_tuple.Make_int_double(1, 2.5)
	t7 := li_std_tuple.Make_int_double(10, 20.0)
	t8 := li_std_tuple.Pass_tuples(t6, t7)
	_ = t8

	// Clean up
	li_std_tuple.DeleteIntDoubleTuple(t)
	li_std_tuple.DeleteIntDoubleTuple(t2)
	li_std_tuple.DeleteIntDoubleTuple(t3)
	li_std_tuple.DeleteIntDoubleTuple(t5)
	li_std_tuple.DeleteIntDoubleTuple(t6)
	li_std_tuple.DeleteIntDoubleTuple(t7)
	li_std_tuple.DeleteIntDoubleTuple(t8)
}
