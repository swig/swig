# file: runme.py

import example

# The first parameter and any strings passed here need to be byte strings.
example.printf(b'Testing\n')
example.printf(b'Testing %s %d %c %.0f\n', b'libffi', 1, 50, 3.0)

# The first two arguments need to be Unicode strings for Python 3, but the
# remaining arguments need to be bytes!
example.execlp('/bin/ls', 'ls', b'-l')
