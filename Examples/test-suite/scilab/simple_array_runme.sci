exec loader.sce

initArray();
if x_get() <> int32([0,1,2,3,4,5,6,7,8,9]) then pause, end
if y_get() <> [0/7,1/7,2/7,3/7,4/7,5/7,6/7] then pase, end

exit
