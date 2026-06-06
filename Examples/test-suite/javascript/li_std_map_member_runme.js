var li_std_map_member = require("li_std_map_member");

a = new li_std_map_member.mapita();
a.set(1, new li_std_map_member.TestA());

if ((a.get(1).i != 1)) {
    throw new Error("a[1] != 1");
}

a.get(1).i = 2;
if ((a.get(1).i != 2)) {
    throw new Error("a[1] != 2");
}
