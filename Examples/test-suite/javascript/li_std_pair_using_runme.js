var li_std_pair_using = require("li_std_pair_using");

var one = new li_std_pair_using.StringStringPair("one", "numero uno");
var two = new li_std_pair_using.StringIntPair("two", 2);

var tuple = /* await */(li_std_pair_using.bounce(one));
if (typeof tuple !== 'object' && tuple.first !== one.first || tuple.second !== one.second) {
    throw new Error;
}
