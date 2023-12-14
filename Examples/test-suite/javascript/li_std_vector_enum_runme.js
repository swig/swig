var li_std_vector_enum = require("li_std_vector_enum");


function check(a, b) {
    if ((a != b)) {
        throw new Error("Not equal: ", a, b);
    }
}

var ev = new li_std_vector_enum.EnumVector();

check(/* await */(ev.nums.get(0)), 10);
check(/* await */(ev.nums.get(1)), 20);
check(/* await */(ev.nums.get(2)), 30);

var expected = 10;
for (let i = 0; i < /* await */(ev.nums.size()); i++) {
    let val = /* await */(ev.nums.get(i));
    check(val, expected);
    expected += 10;
}
