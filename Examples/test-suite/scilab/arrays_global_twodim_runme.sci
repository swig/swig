exec loader.sce;

a = [1, 2, 3, 4; 5, 6, 7, 8;]
array_d_set(a);
if array_d_get() <> a then pause, end

exit
