require 'example'

# This should invoke foo(double)
Example::foo(3.14159)

# This should invoke foo(double, char *)
Example::foo(3.14159, "Pi")

# This should invoke foo(int, int)
Example::foo(3, 4)

# This should invoke foo(char *)
Example::foo("This is a test")

# This should invoke foo(long)
Example::foo(42)

# This should invoke foo(Bar *)
Example::foo(Example::Bar.new)

# This should invoke Bar(double)
Example::Bar.new(3.14159)

# This should invoke Bar(double, char *)
Example::Bar.new(3.14159, "Pi")

# This should invoke Bar(int, int)
Example::Bar.new(3, 4)

# This should invoke Bar(char *)
Example::Bar.new("This is a test")

# This should invoke Bar(long)
Example::Bar.new(42)

# This should invoke Bar() for the input argument, followed by Bar(const Bar&)
Example::Bar.new(Example::Bar.new)
