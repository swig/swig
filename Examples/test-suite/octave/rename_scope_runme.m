rename_scope

a = Natural_UP();
b = Natural_BP();

if (a.rtest() != 1)
    error("failed");
endif

if (b.rtest() != 1)
    error("failed");
endif

f = @equals;

