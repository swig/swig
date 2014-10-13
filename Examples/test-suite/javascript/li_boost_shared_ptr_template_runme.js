var li_boost_shared_ptr_template = require("li_boost_shared_ptr_template");

b = new li_boost_shared_ptr_template.BaseINTEGER()
d = new li_boost_shared_ptr_template.DerivedINTEGER()
if (b.bar() != 1)
    throw new Error("Expected 1");
if (d.bar() != 2)
    throw new Error("Expected 2");
if (li_boost_shared_ptr_template.bar_getter(b) != 1)
    throw new Error("expected not 1");

b = new li_boost_shared_ptr_template.BaseDefaultInt()
d = new li_boost_shared_ptr_template.DerivedDefaultInt()
d2 = new li_boost_shared_ptr_template.DerivedDefaultInt2()
if (b.bar2() != 3)
    throw new Error("expected not 3");
if (d.bar2() != 4)
    throw new Error("expected not 4");
if (d2.bar2() != 4)
    throw new Error("expected not 4");
if (li_boost_shared_ptr_template.bar2_getter(b) != 3)
    throw new Error("expected not 3");
