var li_factory = require("li_factory");

var circle = /* await */(li_factory.Geometry.create(li_factory.Geometry.CIRCLE));
/* @ts-ignore : TS can not know that create can return a Circle */
var r = /* await */(circle.radius());
if ((r != 1.5)) {
    throw new Error;
}

var point = /* await */(li_factory.Geometry.create(li_factory.Geometry.POINT));
/* @ts-ignore */
var w = /* await */(point.width());
if ((w != 1.0)) {
    throw new Error;
}
