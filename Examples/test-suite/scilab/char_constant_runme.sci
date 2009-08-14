exec loader.sce;

if CHAR_CONSTANT_get() <> 'x' then pause, end
if STRING_CONSTANT_get() <> "xyzzy" then pause, end
if ESC_CONST_get() <> ascii(1) then pause, end
if ia_get() <> ascii('a') then pause, end
if ib_get() <> ascii('b') then pause, end

exit
