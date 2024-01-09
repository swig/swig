var memberin_extend_c = require("memberin_extend_c");

var t = new memberin_extend_c.Person();
t.name = "Fred Bloggs";
if (t.name != "FRED BLOGGS") {
    throw new Error("name wrong");
}
