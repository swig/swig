var keyword_rename = require("keyword_rename")
keyword_rename._instanceof(1)
keyword_rename._finally(1)
keyword_rename._yield(0)

var s = keyword_rename.make_S_with_yield(17);

if (s.yield != 17)
    throw new Error;

if (s._yield == 17)
    throw new Error;
