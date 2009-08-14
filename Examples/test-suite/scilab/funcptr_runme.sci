exec loader.sce;

if add(7, 9) <> 16 then pause, end
if do_op(7, 9, funcvar_get()) <> 16 then pause, end

exit
