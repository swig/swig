%module xxx

int f(int);

// A stray '}' is still reported after skipping a decltype operand the grammar cannot parse, whatever brackets it has.
decltype((f)({1})) braced_argument = 1;
}
void take(decltype((f)({1})) c, int n);
}
decltype([] { return f(1); }()) lambda_call = 1;
}
