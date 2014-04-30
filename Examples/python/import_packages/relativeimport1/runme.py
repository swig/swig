# Test import of modules content from within __init__.py
print "Testing %module(package=...) with -relativeimport"
import sys
if sys.version_info < (3,0):
  import py2.pkg2.bar
  print "  Finished importing py2.pkg2.bar"
else:
  import py3.pkg2.bar
  print "  Finished importing py3.pkg2.bar"
