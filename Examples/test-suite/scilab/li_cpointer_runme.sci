exec loader.sce;

p = new_intp();
intp_assign(p,3);

if intp_value(p) <> 3 then pause, end

exit
