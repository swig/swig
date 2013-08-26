lines(0);
exec loader.sce;
SWIG_Init();


disp(mean([1,2,3,4]));

// ... or a wrapped std::vector<int>

v = new_IntVector();
for i = 1:4
    IntVector_push_back(v, i);
end;
disp(average(v));


// half will return a Scilab matrix.
// Call it with a Scilab matrix...

disp(half([1.0, 1.5, 2.0, 2.5, 3.0]));


// ... or a wrapped std::vector<double>

v = new_DoubleVector();
for i = 1:4
    DoubleVector_push_back(v, i);
end;
disp(half(v));

// now halve a wrapped std::vector<double> in place

halve_in_place(v);
disp(v);

exit

