exec loader.sce

a = new_Bar();
Bar_x_set(a,100);
if Bar_x_get(a) <> 100 then pause,end

exit
