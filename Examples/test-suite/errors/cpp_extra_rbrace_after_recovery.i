%module xxx

int f(int);

// A stray '}' is still reported after skipping an unparsable decltype operand or 'new auto' initialiser containing braces.
decltype((f)({1})) braced_argument = 1;
}
void take(decltype((f)({1})) c, int n);
}
decltype([] { return f(1); }()) lambda_call = 1;
}
auto new_braced_argument = new auto((f)({1}));
}
void take_new(int *p = new auto((f)({1})), int n = 1);
}
