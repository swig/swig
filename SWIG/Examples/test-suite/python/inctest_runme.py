import inctest

try:
  a = inctest.A()
except:
  print "didn't find A"
  print "therefore, I didn't include 'testdir/subdir1/hello.i'"
  error = 1
pass


try:
  b = inctest.B()
except:
  print "didn't find B"
  print "therefore, I didn't include 'testdir/subdir2/hello.i'"
  error = 1
pass

if error == 1:
  raise RuntimeError

