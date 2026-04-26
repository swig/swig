local v=require("cpp11_copyctor_delete")

-- check copy constructors are generated
v.CopyCtorDeletedPublic1(v.CopyCtorDeletedPublic1.make())
v.CopyCtorDeletedProtected1(v.CopyCtorDeletedProtected1.make())
v.CopyCtorDeletedPrivate1(v.CopyCtorDeletedPrivate1.make())

v.DeletedPublic4()
v.DeletedPublic5()
v.CopyCtorDeletedPublic4()
v.CopyCtorDeletedPublic5()

v.StackOnly1()
v.CopyCtorStackOnly1(v.CopyCtorStackOnly1())
