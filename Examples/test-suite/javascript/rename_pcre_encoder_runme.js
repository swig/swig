var rename_pcre_encoder = require("rename_pcre_encoder");

s = new rename_pcre_encoder.SomeWidget();
s.put_borderWidth(3);
if (s.get_borderWidth() != 3) {
    throw new Error(`Border should be 3, not ${s.get_borderWidth()}`);
}

s.put_size(4, 5);
a = new rename_pcre_encoder.AnotherWidget();
a.DoSomething();

evt = new rename_pcre_encoder.wxEVTSomeEvent();
t = new rename_pcre_encoder.xUnchangedName();

if (rename_pcre_encoder.StartINSAneAndUNSAvoryTraNSAtlanticRaNSAck() != 42) {
    throw new Error("Unexpected result of renamed function call");
}
