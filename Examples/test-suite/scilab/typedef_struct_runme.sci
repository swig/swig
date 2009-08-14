exec loader.sce

x = new_LineObj();
LineObj_numpoints_set(x, 100);
if LineObj_numpoints_get(x) <> 100 then pause, end

if MS_NOOVERRIDE_get() <> -1111 then pause, end

y = make_a();
A_t_a_set(y, 200);
if A_t_a_get(y) <> 200 then pause, end
A_t_b_set(y, 300);
if A_t_b_get(y) <> 300 then pause, end

exit

