var li_factory = require("li_factory");

circle = li_factory.Geometry.create(li_factory.Geometry.CIRCLE);
r = circle.radius();
if ((r != 1.5)) {
    throw new Error;
}

point = li_factory.Geometry.create(li_factory.Geometry.POINT);
w = point.width();
if ((w != 1.0)) {
    throw new Error;
}
