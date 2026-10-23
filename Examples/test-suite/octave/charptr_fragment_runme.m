charptr_fragment

if (!strcmp(charptr_fragment.getCharBuf(), "hello"))
   error("getCharBuf failed");
endif

if (!strcmp(charptr_fragment.getBinaryCharBuf(), "hello"))
   error("getBinaryCharBuf failed");
endif
