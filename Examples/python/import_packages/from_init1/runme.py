# Test import of modules content from within __init__.py
print "Testing %module(package=...) + python 'import' in __init__.py"
import sys
if sys.version_info < (3,0):
  import py2.pkg2
  print "  Finished importing py2.pkg2"
else:
  import py3.pkg2
  print "  Finished importing py3.pkg2"
