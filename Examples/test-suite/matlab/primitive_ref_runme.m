import primitive_ref.*

if (ref_int(3) ~= 3)
    error
end

if (ref_uint(3) ~= 3)
    error
end

if (ref_short(3) ~= 3)
    error
end

if (ref_ushort(3) ~= 3)
    error
end

if (ref_long(3) ~= 3)
    error
end

if (ref_ulong(3) ~= 3)
    error
end

if (ref_schar(3) ~= 3)
    error
end

if (ref_uchar(3) ~= 3)
    error
end

if (ref_float(3.5) ~= 3.5)
    error
end

if (ref_double(3.5) ~= 3.5)
    error
end

if (ref_bool(true) ~= true)
    error
end

if (~strcmp(ref_char('x'),'x'))
    error
end

if (ref_over(0) ~= 0)
    error
end
