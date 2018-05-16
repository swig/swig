import sys
# Package brave found under one path
sys.path.insert(0, 'path1')

from brave import robin

if not(robin.run() == "AWAY!"):
    raise RuntimeError("test failed")
