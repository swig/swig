from director_string import *

class B(A):
  def __init__(self,string):
    A.__init__(self,string)



b = B("hello")

b.get(0)
b.get_first()
