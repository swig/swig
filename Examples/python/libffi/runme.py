# file: runme.py

import example

example.printf('Testing\n')
example.printf('Testing %s %d %c %.0f\n', 'libffi', 1, 50, 3.0)

example.execlp('/bin/ls', 'ls', '-l')
