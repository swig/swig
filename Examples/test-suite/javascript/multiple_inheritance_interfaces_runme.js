var mii = require("multiple_inheritance_interfaces");

let undesirables = new mii.UndesirablesDerived();
undesirables.UndesiredVariable = 42;
if (undesirables.UndesiredVariable != 42) {
    throw Error(`value=${undesirables.UndesiredVariable} instead of expected 42`);
}
