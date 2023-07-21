// In JavaScript, std::map has very limited capabilities and no iterator at all
var li_std_map = require("li_std_map");

/* async */ function set_check(container, idx, value, size) {
    /* await */(container.set(idx, value));
    if (/* await */(container.get(idx)) !== value)
        throw new Error(
          `Failed setting value at ${idx} in ${container.toString()} to ${value}, got ${/* await */(container.getitem(idx))}`);
    if (/* await */(container.size()) != size)
        throw new Error(`Expected a size of ${size}, got ${/* await */(container.size())}`);
}

/* async */ function err_check(container, idx, value, size) {
    let fail = true;
    try {
        /* await */(container.set(idx, value));
    } catch {
        fail = false;
    }
    if (fail) throw new Error(
        `Expected an exception setting value at ${idx} in ${container.toString()} to ${value}, got ${/* await */(container.get(idx))}`);
    if (/* await */(container.size()) != size)
        throw new Error(`Expected a size of ${size}, got ${/* await */(container.size())}`);
}

var map;

map = new li_std_map.IntIntMap();
/* await */(set_check(map, 0, 10, 1));
/* await */(set_check(map, 1, 0, 2));
/* await */(set_check(map, 2, 20, 3));
/* await */(err_check(map, 0, 'string', 3));

if (!/* await */(map.has_key(2))) throw new Error('Expected key to be found');
if (/* await */(map.has_key(5))) throw new Error('Expected key to not be found');
/* await */(map.del(2));
if (/* await */(map.has_key(2))) throw new Error('Expected key to not be found');


map = new li_std_map.StringIntMap();
/* await */(set_check(map, '0', 10, 1));
/* await */(set_check(map, '1', 0, 2));
/* await */(set_check(map, '2', 20, 3));
/* await */(err_check(map, '0', 'string', 3));

if (!/* await */(map.has_key('2'))) throw new Error('Expected key to be found');
if (/* await */(map.has_key('5'))) throw new Error('Expected key to not be found');
/* await */(map.del('2'));
if (/* await */(map.has_key('2'))) throw new Error('Expected key to not be found');
