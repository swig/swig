var li_std_map = require("li_std_map");

var collectionSize = 20;
var midCollection = collectionSize / 2;

// Set up an string to int map
var simap = new li_std_map.StringIntMap();
for (var i = 0; i < collectionSize; i++) {
    var val = i * 18;
    simap.set(i.toString(), val);
}

if (simap.size() != collectionSize)
    throw "Size test failed";

// Item indexing test
simap.set("0", 200);
if (simap.get("0") != 200)
    throw "Item property test failed";
simap.set("0", 0 * 18);

// Key presence test
for (var i = 0; i < collectionSize; i++) {
    if (!simap.has_key(i.toString()))
        throw "has_key test " + i + " failed";
}

// Delete test
simap.del("7");
if (simap.has_key("7"))
    throw "Delete test failed";

// Clear test
simap.clear();
if (simap.size() != 0)
    throw "Clear test failed";

// Custom compare function
var slmap = new li_std_map.StringLengthNumberMap();
li_std_map.populate(slmap);

var keys = slmap.keys();
var keys_array = [];
for (var i = 0; i < keys.size(); i++)
    keys_array.push(keys.get(i));
if (keys_array.join(" ") != "a aa zzz xxxx aaaaa")
    throw "Keys are wrong or in wrong order: " + keys_array;
