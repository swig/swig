%module typemap_arrays

// Test that previously non-working array typemaps special variables are working

%typemap(in) SWIGTYPE[ANY] {
  _should_not_be_used_and_will_not_compile_
}

// Check $basemangle expands to _p_int and $basetype expands to int *
%typemap(in) int *nums[3] (int *temp[3]) {
  $basetype var1$basemangle = new int(10);
  $basetype var2$basemangle = new int(20);
  $basetype var3$basemangle = new int(30);
  temp[0] = var1_p_int;
  temp[1] = var2_p_int;
  temp[2] = var3_p_int;
  $1 = temp;
}

%inline %{
int sumA(int *nums[3]) {
  int sum = 0;
  for (int i=0; i<3; ++i) {
    int *p = nums[i];
    if (p)
      sum += *p;
  }
  return sum;
}
%}

// Check $1_size parenthesises array dimensions that are expressions
%typemap(in) int grid[ANY][ANY] (int temp[$1_dim0][$1_dim1]) {
  temp[0][0] = $1_size;
  $1 = temp;
}
%typemap(in) int row[ANY] (int temp[$1_dim0]) {
  temp[0] = 2 * $1_size;
  $1 = temp;
}
%typemap(freearg) int row[ANY] ""

%inline %{
#define GRID_DIM 2
int gridSize(int grid[GRID_DIM + 1][GRID_DIM + 2]) {
  return grid[0][0];
}
int rowSize(int row[GRID_DIM + 1]) {
  return row[0];
}
%}
