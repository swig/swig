exec("swigtest.start", -1);

try
    outer = new_Outer();
    setValues(outer, 10);

    inner1 = Outer_inner1_get(outer);
    inner2 = Outer_inner2_get(outer);
    inner3 = Outer_inner3_get(outer);
    inner4 = Outer_inner4_get(outer);
catch
    swigtesterror();
end

if Outer_inner1_val_get(inner1) <> 10 then swigtesterror(); end
if Outer_inner2_val_get(inner2) <> 20 then swigtesterror(); end
if Outer_inner3_val_get(inner3) <> 20 then swigtesterror(); end
if Outer_inner4_val_get(inner4) <> 40 then swigtesterror(); end

try
    inside1 = Outer_inside1_get(outer);
    inside2 = Outer_inside2_get(outer);
    inside3 = Outer_inside3_get(outer);
    inside4 = Outer_inside4_get(outer);
catch
    swigtesterror();
end

if Outer_inside1_val_get(inside1) <> 100 then swigtesterror(); end
if Outer_inside2_val_get(inside2) <> 200 then swigtesterror(); end
if Outer_inside3_val_get(inside3) <> 200 then swigtesterror(); end
if Outer_inside4_val_get(inside4) <> 400 then swigtesterror(); end

exec("swigtest.quit", -1);