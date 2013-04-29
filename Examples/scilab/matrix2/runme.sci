// loader the *.so
exec loader.sce

myMatrix=[ 103 3 1    12;0   0 2043 1];
m=sumitems_argoutput(myMatrix)
myOtherMatrix=getValues();
size(myOtherMatrix)
disp(myOtherMatrix);
exit
