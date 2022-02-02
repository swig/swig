primitive_ref

if (ref_int(3) != 3)
    error("failed");
endif

if (ref_uint(3) != 3)
    error("failed");
endif

if (ref_short(3) != 3)
    error("failed");
endif

if (ref_ushort(3) != 3)
    error("failed");
endif

if (ref_long(3) != 3)
    error("failed");
endif

if (ref_ulong(3) != 3)
    error("failed");
endif

if (ref_schar(3) != 3)
    error("failed");
endif

if (ref_uchar(3) != 3)
    error("failed");
endif

if (ref_float(3.5) != 3.5)
    error("failed");
endif

if (ref_double(3.5) != 3.5)
    error("failed");
endif

if (ref_bool(true) != true)
    error("failed");
endif

if (!strcmp(ref_char('x'),'x'))
    error("failed");
endif

if (ref_over(0) != 0)
    error("failed");
endif
