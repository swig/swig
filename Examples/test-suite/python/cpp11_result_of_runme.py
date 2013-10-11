import cpp11_result_of
if cpp11_result_of.test_result(cpp11_result_of.square, 3.0) != 9.0:
	raise RuntimeError, "test_result(square, 3.0) is not 9.0."
