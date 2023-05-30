// In JS std::vector and std::list cannot behave as native containers
// because there is no overloading
var li_std_containers_int = require("li_std_containers_int");

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

var vector;

vector = new li_std_containers_int.vector_int();
err_check(vector, 0, 10, 0);

vector = new li_std_containers_int.vector_int(2);
set_check(vector, 0, 10, 2);
set_check(vector, 1, 0, 2);
err_check(vector, 2, 20, 2);
err_check(vector, 0, 'string', 2);
err_check(vector, 0, {}, 2);
