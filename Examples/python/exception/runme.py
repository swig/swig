# file: runme.py

# Throw a lot of exceptions

import example

t = example.Test()
try:
      t.unknown()
except RuntimeError,e:
      print "incomplete type", e.args[0]

try:
      t.simple()
except RuntimeError,e:
      print e.args[0]

try:
      t.message()
except RuntimeError,e:
      print e.args[0]

try:
      t.hosed()
except example.Exc,e:
      print e.code, e.msg

for i in range(1,4):
      try:
            t.multi(i)
      except RuntimeError,e:
            print e.args[0]
      except example.Exc,e:
            print e.code, e.msg


