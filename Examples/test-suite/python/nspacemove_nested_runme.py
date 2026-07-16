import nspacemove_nested as nspace


cases = (
    (nspace.Space, "1"),
    (nspace.Space, "2"),
    (nspace.NewSpace3, "3"),
    (nspace.NewSpace4, "4"),
    (nspace, "5"),
    (nspace, "6"),
    (nspace, "7"),
    (nspace.Space, "10"),
    (nspace.Space, "20"),
    (nspace.NewOkay30, "30"),
    (nspace.NewOkay40, "40"),
    (nspace.NewOkay50, "50"),
    (nspace, "60"),
    (nspace, "70"),
    (nspace.Space, "80"),
)

for scope, suffix in cases:
    outer_type = getattr(scope, "OuterClass" + suffix)
    inner_type = getattr(scope, "InnerClass" + suffix)
    bottom_type = getattr(scope, "BottomClass" + suffix)
    outer = outer_type()
    inner = inner_type()
    bottom = bottom_type()
    enum_value = getattr(outer_type, "ie" + suffix + "a")
    outer.take(enum_value, inner)
