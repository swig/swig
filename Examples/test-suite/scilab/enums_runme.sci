exec("swigtest.start", -1);

try
    bar1(CSP_ITERATION_FWD_get())
    bar1(CSP_ITERATION_BWD_get())
    bar1(int32(1))

    bar2(ABCDE_get())
    bar2(FGHJI_get())
    bar2(int32(1))

    bar3(ABCDE_get())
    bar3(FGHJI_get())
    bar3(int32(1))
catch
    swigtesterror()
end

if enumInstance_get() <> int32(2) then swigtesterror(); end
if Slap_get() <> int32(10) then swigtesterror(); end
if My_get() <> int32(11) then swigtesterror(); end
if Thigh_get() <> int32(12) then swigtesterror(); end

exec("swigtest.quit", -1);