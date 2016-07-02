circle = li_factory.Geometry_create(Geometry.CIRCLE);
r = circle.radius();
if (r ~= 1.5)
  error
end

point = li_factory.Geometry_create(Geometry.POINT);
w = point.width();
if (w ~= 1.0)
  error
end
