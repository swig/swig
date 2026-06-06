var li_std_vector_enum = require("li_std_vector_enum");


function check(a, b) {
    if ((a != b)) {
        throw new Error("Not equal: ", a, b);
    }
}

ev = new li_std_vector_enum.EnumVector();

check(ev.nums.get(0), 10);
check(ev.nums.get(1), 20);
check(ev.nums.get(2), 30);

expected = 10;
for (let i = 0; i < ev.nums.size(); i++) {
    let val = ev.nums.get(i);
    check(val, expected);
    expected += 10;
}
