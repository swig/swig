var template_default_arg_overloaded = require("template_default_arg_overloaded");

function check(expected, got) {
  if (expected != got) {
    throw new Error("Expected: " + str(expected) + " got: " + str(got));
  }
}


pl = new template_default_arg_overloaded.PropertyList();
check(1, pl.setInt("int", 10));
check(1, pl.setInt("int", 10, false));

check(2, pl.set("int", pl));
check(2, pl.set("int", pl, false));

check(3, pl.setInt("int", 10, "int"));
check(3, pl.setInt("int", 10, "int", false));


pl = new template_default_arg_overloaded.PropertyListGlobal();
check(1, pl.setIntGlobal("int", 10));
check(1, pl.setIntGlobal("int", 10, false));

check(2, pl.set("int", pl));
check(2, pl.set("int", pl, false));

check(3, pl.setIntGlobal("int", 10, "int"));
check(3, pl.setIntGlobal("int", 10, "int", false));


check(1, template_default_arg_overloaded.GoopIntGlobal(10));
check(1, template_default_arg_overloaded.GoopIntGlobal(10, true));

check(2, template_default_arg_overloaded.goopGlobal(3));
check(2, template_default_arg_overloaded.goopGlobal());

check(3, template_default_arg_overloaded.GoopIntGlobal("int", false));
check(3, template_default_arg_overloaded.GoopIntGlobal("int"));


check(1, template_default_arg_overloaded.GoopInt(10));
check(1, template_default_arg_overloaded.GoopInt(10, true));

check(2, template_default_arg_overloaded.goop(3));
check(2, template_default_arg_overloaded.goop());

check(3, template_default_arg_overloaded.GoopInt("int", false));
check(3, template_default_arg_overloaded.GoopInt("int"));
