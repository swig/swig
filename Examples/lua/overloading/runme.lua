require('example')

-- This should invoke foo(double)
example.foo(3.14159)

-- This should invoke foo(double, char *)
example.foo(3.14159, "Pi")

-- This should invoke foo(int, int)
example.foo(3, 4)

-- This should invoke foo(char *)
example.foo("This is a test")

-- This should invoke foo(long)
example.foo(42)

-- This should invoke Bar.Bar() followed by foo(Bar *)
example.foo(example.Bar())

-- Skip a line
print()

-- Each of the following three calls should invoke spam(int, int, int)
example.spam(3)
example.spam(3, 4)
example.spam(3, 4, 5)

-- Skip a line
print()

-- Each of the following three calls should invoke spam(double, int, int)
example.spam(3.0)
example.spam(3.0, 4)
example.spam(3.0, 4, 5)

-- Skip a line
print()

-- This should invoke Bar.Bar(double)
example.Bar(3.14159)

-- This should invoke Bar.Bar(double, char *)
example.Bar(3.14159, "Pi")

-- This should invoke Bar.Bar(int, int)
example.Bar(3, 4)

-- This should invoke Bar.Bar(char *)
example.Bar("This is a test")

-- This should invoke Bar.Bar(int)
example.Bar(42)

-- This should invoke Bar.Bar() for the input argument,
-- followed by Bar.Bar(const Bar&).
example.Bar(example.Bar())

-- Skip a line
print()

-- Construct a new Bar instance (invokes Bar.Bar())
local bar = example.Bar()

-- This should invoke Bar.foo(double)
bar:foo(3.14159)

-- This should invoke Bar.foo(double, char *)
bar:foo(3.14159, "Pi")

-- This should invoke Bar.foo(int, int)
bar:foo(3, 4)

-- This should invoke Bar.foo(char *)
bar:foo("This is a test")

-- This should invoke Bar.foo(int)
bar:foo(42)

-- This should invoke Bar.Bar() to construct the input
-- argument, followed by Bar.foo(Bar *).
bar:foo(example.Bar())

-- This should invoke Bar.spam(int x, int y, int z)
bar:spam(1)

-- This should invoke Bar.spam(double x, int y, int z)
bar:spam(3.14159)
