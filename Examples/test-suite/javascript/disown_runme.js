var disown = require("disown");

var a = new disown.A();
/* @ts-ignore */
var tmp = a.thisown;
/* @ts-ignore */
a.thisown = 0;
/* @ts-ignore */
if (a.thisown) {
  throw new Error("Failed.");
}
/* @ts-ignore */
a.thisown = 1;
/* @ts-ignore */
if (!a.thisown) {
  throw new Error("Failed.");
}
/* @ts-ignore */
a.thisown = tmp;
/* @ts-ignore */
if (a.thisown != tmp) {
  throw new Error("Failed.");
}

var b = new disown.B();
/* @ts-ignore */
/* await */(b.acquire(a));
/* @ts-ignore */
if (a.thisown) {
  throw new Error("Failed.");
}
