// In JavaScript, std::map has very limited capabilities and no iterator at all
var li_std_map = require("li_std_map");

function set_check(container, idx, value, size) {
    container.set(idx, value);
    if (container.get(idx) !== value)
        throw new Error(
            `Failed setting value at ${idx} in ${container.toString} to ${value}, got ${container.getitem(idx)}`);
    if (container.size() != size)
        throw new Error(`Expected a size of ${size}, got ${container.size()}`);
}

function err_check(container, idx, value, size) {
    let fail = true;
    try {
        container.set(idx, value);
    } catch {
        fail = false;
    }
    if (fail) throw new Error(
        `Expected an exception setting value at ${idx} in ${container.toString} to ${value}, got ${container.get(idx)}`);
    if (container.size() != size)
        throw new Error(`Expected a size of ${size}, got ${container.size()}`);
}

var map;

map = new li_std_map.IntIntMap();
set_check(map, 0, 10, 1);
set_check(map, 1, 0, 2);
set_check(map, 2, 20, 3);
err_check(map, 0, 'string', 3);

if (!map.has_key(2)) throw new Error('Expected key to be found');
if (map.has_key(5)) throw new Error('Expected key to not be found');
map.del(2);
if (map.has_key(2)) throw new Error('Expected key to not be found');


map = new li_std_map.StringIntMap();
set_check(map, '0', 10, 1);
set_check(map, '1', 0, 2);
set_check(map, '2', 20, 3);
err_check(map, '0', 'string', 3);

if (!map.has_key('2')) throw new Error('Expected key to be found');
if (map.has_key('5')) throw new Error('Expected key to not be found');
map.del('2');
if (map.has_key('2')) throw new Error('Expected key to not be found');
