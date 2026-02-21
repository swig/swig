var template_rename = require("template_rename");

var i = new template_rename.iFoo();
var d = new template_rename.dFoo();

var a = i.blah_test(4);
var b = i.spam_test(5);
var c = i.groki_test(6);

var x = d.blah_test(7);
var y = d.spam(8);
var z = d.grok_test(9);
