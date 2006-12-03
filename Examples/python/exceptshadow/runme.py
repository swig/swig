# file: runme.py
import example

q = example.intQueue(10)

print "Inserting items into intQueue"

try:
      for i in range(0,100):
            q.enqueue(i)
except example.FullError,e:
      print "Maxsize is", e.maxsize

print "Removing items"

try:
      while 1:
            q.dequeue()
except example.EmptyError,e:
      pass


q = example.doubleQueue(1000)

print "Inserting items into doubleQueue"

try:
      for i in range(0,10000):
            q.enqueue(i*1.5)
except example.FullError,e:
      print "Maxsize is", e.maxsize

print "Removing items"

try:
      while 1:
            q.dequeue()
except example.EmptyError,e:
      pass





      
