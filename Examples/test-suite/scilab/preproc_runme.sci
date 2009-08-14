exec loader.sce;

if endif_get() <> 1 then pause, end
if define_get() <> 1 then pause, end
if defined_get() <> 1 then pause ,end
if 2 * one_get() <> two_get() then pause, end
  
exit
