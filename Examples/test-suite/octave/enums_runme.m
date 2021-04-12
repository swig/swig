
enums

enums.bar2(1)
enums.bar3(1)
enums.bar1(1)

if (enums.cvar.enumInstance != 2)
  error("failed");
endif

if (enums.cvar.Slap != 10)
  error("failed");
endif

if (enums.cvar.Mine != 11)
  error("failed");
endif

if (enums.cvar.Thigh != 12)
  error("failed");
endif

