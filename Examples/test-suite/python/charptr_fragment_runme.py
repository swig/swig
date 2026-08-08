import charptr_fragment

if charptr_fragment.getCharBuf() != "hello":
    raise RuntimeError("getCharBuf failed")

if charptr_fragment.getBinaryCharBuf() != "hello":
    raise RuntimeError("getBinaryCharBuf failed")
