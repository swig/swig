import python_charptr_fragment

if python_charptr_fragment.getStr() != 'test1':
    raise runtimeerror("wrong getstr value")

t = python_charptr_fragment.tst_str2()
if t.getStr() != 'test2':
    raise runtimeerror("wrong tst_str2::getstr value")
