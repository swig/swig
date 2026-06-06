var li_std_pair_using = require("li_std_pair_using");

one = new li_std_pair_using.StringStringPair("one", "numero uno");
two = new li_std_pair_using.StringIntPair("two", 2);

tuple = li_std_pair_using.bounce(one);
if (typeof tuple !== 'object' && tuple.first !== one.first || tuple.second !== one.second) {
    throw new Error;
}
