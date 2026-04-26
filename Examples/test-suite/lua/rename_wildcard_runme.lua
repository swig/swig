local v=require("rename_wildcard")

-- Wildcard check
v.GlobalWildStruct():mm1()
v.GlobalWildTemplateStructInt():mm1()
v.SpaceWildStruct():mm1()
v.SpaceWildTemplateStructInt():mm1()

-- No declaration
v.GlobalWildStruct():mm2a()
v.GlobalWildTemplateStructInt():mm2b()
v.SpaceWildStruct():mm2c()
v.SpaceWildTemplateStructInt():mm2d()

v.GlobalWildTemplateStructInt():tt2b()
v.SpaceWildTemplateStructInt():tt2d()

-- With declaration
v.GlobalWildStruct():mm3a()
v.GlobalWildTemplateStructInt():mm3b()
v.SpaceWildStruct():mm3c()
v.SpaceWildTemplateStructInt():mm3d()

v.GlobalWildTemplateStructInt():tt3b()
v.SpaceWildTemplateStructInt():tt3d()

-- Global override too
v.GlobalWildStruct():mm4a()
v.GlobalWildTemplateStructInt():mm4b()
v.SpaceWildStruct():mm4c()
v.SpaceWildTemplateStructInt():mm4d()

v.GlobalWildTemplateStructInt():tt4b()
v.SpaceWildTemplateStructInt():tt4d()

-- %extend renames
v.GlobalWildStruct():mm5a()
v.GlobalWildTemplateStructInt():mm5b()
v.SpaceWildStruct():mm5c()
v.SpaceWildTemplateStructInt():mm5d()

v.GlobalWildTemplateStructInt():tt5b()
v.SpaceWildTemplateStructInt():tt5d()

-- operators
v.GlobalWildStruct():opinta()
v.GlobalWildTemplateStructInt():opintb()
v.SpaceWildStruct():opintc()
v.SpaceWildTemplateStructInt():opintd()

v.GlobalWildTemplateStructInt():opdoubleb()
v.SpaceWildTemplateStructInt():opdoubled()

-- Wildcard renames expected for these
v.NoChangeStruct():mm1()
v.NoChangeStruct():mm2()
v.NoChangeStruct():mm3()
v.NoChangeStruct():mm4()
v.NoChangeStruct():mm5()
v.NoChangeStruct():opint()
v.SpaceNoChangeStruct():mm1()
v.SpaceNoChangeStruct():mm2()
v.SpaceNoChangeStruct():mm3()
v.SpaceNoChangeStruct():mm4()
v.SpaceNoChangeStruct():mm5()
v.SpaceNoChangeStruct():opint()
