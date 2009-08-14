exec loader.sce;

small = new_SmallStruct();
SmallStruct_jill_set(small, 200);

big = new_BigStruct();
BigStruct_jack_set(big, 300);

Jill = SmallStruct_jill_get(small);
if Jill <> 200 then pause, end

Jack = BigStruct_jack_get(big);
if Jack <> 300 then pause, end

exit
