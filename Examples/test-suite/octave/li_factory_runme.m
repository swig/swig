# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

li_factory

circle = Geometry_create(Geometry.CIRCLE);
r = circle.radius();
if (r != 1.5)
  error("failed");
endif

point = Geometry_create(Geometry.POINT);
w = point.width();
if (w != 1.0)
  error("failed");
endif
