var smart_pointer_templatevariables = require("smart_pointer_templatevariables");

d = new smart_pointer_templatevariables.DiffImContainerPtr_D(smart_pointer_templatevariables.create(1234, 5678));

// TODO xyz has been commented out in the shared test file, find out why

if ((d.id != 1234)) {
    throw new Error;
}
//if ((d.xyz != 5678)) {
//    throw new Error;
//}

d.id = 4321;
//d.xyz = 8765;

if ((d.id != 4321)) {
    throw new Error;
}
//if ((d.xyz != 8765)) {
//    throw new Error;
//}
