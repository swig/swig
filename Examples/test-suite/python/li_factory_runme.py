from li_factory import *

circle = Geometry.create(Geometry.CIRCLE)
r = circle.radius()
if (r != 1.5):
    raise RuntimeError

point = Geometry.create(Geometry.POINT)
w = point.width()
if (w != 1.0):
    raise RuntimeError
