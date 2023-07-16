var li_std_map_member = require("li_std_map_member");

var a = new li_std_map_member.mapita();
/* await */(a.set(1, new li_std_map_member.TestA()));

if ((/* await */(a.get(1))).i != 1) {
    throw new Error("a[1] != 1");
}

(/* await */(a.get(1))).i = 2;
if ((/* await */(a.get(1))).i != 2) {
    throw new Error("a[1] != 2");
}
