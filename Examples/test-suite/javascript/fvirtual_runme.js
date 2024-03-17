var fvirtual = require('fvirtual');

var sw = new fvirtual.NodeSwitch();
var n = new fvirtual.Node();
var i = sw.addChild(n);

if (i != 2)
    throw Error("addChild");
