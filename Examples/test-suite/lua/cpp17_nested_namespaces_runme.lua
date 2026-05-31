local v=require("cpp17_nested_namespaces")

v.A1Struct():A1Method()
v.B1Struct():B1Method()
v.C1Struct():C1Method()

v.createA1Struct():A1Method()
v.createB1Struct():B1Method()
v.createC1Struct():C1Method()

v.B2Struct():B2Method()
v.C2Struct():C2Method()
v.createB2Struct():B2Method()
v.createC2Struct():C2Method()

v.B3Struct():B3Method()
v.C3Struct():C3Method()
v.createB3Struct():B3Method()
v.createC3Struct():C3Method()
