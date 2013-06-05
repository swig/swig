exec loader.sce;

disp("this is an example with sets of int.");
disp("create the set from matrix [1, 2, 4, 4]:");
iset = create_iset(int32([1, 2, 4, 4]));
disp(iset);
s = sum_iset(iset);
disp("sum of this set elements is:");
disp(s);
iset2 = create_iset(int32([1, 10]));
disp("concat this set with the set of int {1, 10}:");
iset3 = concat_iset(iset, iset2);
disp(iset3);



