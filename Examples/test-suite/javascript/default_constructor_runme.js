var default_constructor = require('default_constructor');

var dc = default_constructor;

var a = new dc.A;

var aa = new dc.AA;

try {
  /* @ts-ignore */
  var b = new dc.B();
  throw new SyntaxError('Whoa. B created.');
} catch (e) {
  if (e instanceof SyntaxError) throw e;
}

try {
  /* @ts-ignore */
  var bb = new dc.BB();
  throw new SyntaxError('Whoa. BB created.');
} catch (e) {
  if (e instanceof SyntaxError) throw e;
}

try {
  var c = new dc.C();
  throw new SyntaxError('Whoa. C created.');
} catch (e) {
  if (e instanceof SyntaxError) throw e;
}

var cc = new dc.CC();

try {
  var d = new dc.D();
  throw new SyntaxError('Whoa. D created.');
} catch (e) {
  if (e instanceof SyntaxError) throw e;
}

try {
  var dd = new dc.DD();
  throw new SyntaxError('Whoa. DD created.');
} catch (e) {
  if (e instanceof SyntaxError) throw e;
}

try {
  var ad = new dc.AD();
  throw new SyntaxError('Whoa. AD created.');
} catch (e) {
  if (e instanceof SyntaxError) throw e;
}

var e = new dc.E();

var ee = new dc.EE();

try {
  var eb = new dc.EB();
  throw new SyntaxError('Whoa. EB created.');
} catch (e) {
  if (e instanceof SyntaxError) throw e;
}

// TODO: custom destructors are currently broken for all JavaScript engines
// (ie these objects are never destroyed)
var f = new dc.F();
dc.bar(f);

/* @ts-ignore */
if (typeof f.destroy !== 'undefined') {
  throw new SyntaxError('destroy not deleted');
}

var g = new dc.G();

var gg = new dc.GG();


var hh = new default_constructor.HH(1, 1);
