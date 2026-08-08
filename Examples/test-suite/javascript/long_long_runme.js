// long_long_runme.js
var long_long = require("long_long");
var ll = long_long;

function check(v)
{
	if(!v) {
		throw Error();
	}
}

check(ll.lconst1 == 1234567890);
check(ll.lconst2 == 1234567890);

check(ll.lconst3 == 1234567);
check(ll.lconst4 == 1234567);

check(ll.lconst5 == 987654321);
check(ll.lconst6 == 987654321);

check(ll.lconst1 == ll.UnsignedToSigned(ll.lconst2));
