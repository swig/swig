import sys
import file_test

if sys.version_info < (3,0):
  file_test.nfile(sys.stdout)

cstdout = file_test.GetStdOut()

file_test.nfile(cstdout)
file_test.nfile_name("test.dat")
