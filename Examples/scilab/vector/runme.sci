exec loader.sce;

disp("this is an example with vectors of double.");
disp("create the vector of double {2.0, 2.0, 2.0, 2.0}:");
dv = create_dvector(4, 2.0);
disp(dv);
ds = sum_dvector(dv);
disp("sum of this vector elements is:")
disp(ds);
dv2 = create_dvector(2, 5.0);
disp("concat this vector with the vector of double {5.0, 5.0}:");
dv3 = concat_dvector(dv, dv2);
disp(dv3);

disp("now an example with vectors of int.");
disp("create the vector of int {3, 3, 3}:");
iv = create_ivector(3, 3);
disp(iv);
is = sum_ivector(iv);
disp("sum of this vector elements is:");
disp(is);
iv2 = create_ivector(2, 1);
disp("concat this vector with the vector of ints {1, 1}:");
iv3 = concat_ivector(iv, iv2);
disp(iv3);

disp("now an example with vectors of string.");
disp("create the vector of string {''aa'', ''aa''}:");
sv = create_svector(2, "aa");
print_svector(sv);
sv2 = create_svector(2, "bb");
disp("concat this vector with the vector of string {''bb'', ''bb''}:");
sv3 = concat_svector(sv, sv2);
print_svector(sv3);



