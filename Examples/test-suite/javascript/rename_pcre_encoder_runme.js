var rename_pcre_encoder = require("rename_pcre_encoder");

var s = new rename_pcre_encoder.SomeWidget();
/* await */(s.put_borderWidth(3));
if (/* await */(s.get_borderWidth()) != 3) {
    throw new Error(`Border should be 3, not ${s.get_borderWidth()}`);
}

/* await */(s.put_size(4, 5));
var a = new rename_pcre_encoder.AnotherWidget();
/* await */(a.DoSomething());

var evt = new rename_pcre_encoder.wxEVTSomeEvent();
var t = new rename_pcre_encoder.xUnchangedName();

if (/* await */(rename_pcre_encoder.StartINSAneAndUNSAvoryTraNSAtlanticRaNSAck()) != 42) {
    throw new Error("Unexpected result of renamed function call");
}
