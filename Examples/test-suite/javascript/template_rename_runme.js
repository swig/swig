var template_rename = require("template_rename");

var i = new template_rename.iFoo();
var d = new template_rename.dFoo();

var a = /* await */(i.blah_test(4));
var b = /* await */(i.spam_test(5));
var c = /* await */(i.groki_test(6));

var x = /* await */(d.blah_test(7));
var y = /* await */(d.spam(8));
var z = /* await */(d.grok_test(9));
