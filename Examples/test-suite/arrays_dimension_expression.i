%module arrays_dimension_expression

// Array dimensions containing an operator of lower precedence than the typemap expressions they are used in
%inline %{
#define DIM_FLAGS 3

int or_array[DIM_FLAGS | 4];
int or_source[DIM_FLAGS | 4] = {1, 2, 3, 4, 5, 6, 7};
int or_grid[DIM_FLAGS | 1][2];
int or_grid_source[DIM_FLAGS | 1][2] = {{1, 2}, {3, 4}, {5, 6}};
char or_text[DIM_FLAGS | 4];

int and_array[DIM_FLAGS & 6];
int and_source[DIM_FLAGS & 6] = {1, 2};
int and_grid[DIM_FLAGS & 6][2];
int and_grid_source[DIM_FLAGS & 6][2] = {{1, 2}, {3, 4}};

int xor_array[DIM_FLAGS ^ 4];
int xor_source[DIM_FLAGS ^ 4] = {1, 2, 3, 4, 5, 6, 7};
int xor_grid[2][DIM_FLAGS ^ 4];
int xor_grid_source[2][DIM_FLAGS ^ 4] = {{1, 2, 3, 4, 5, 6, 7}, {8, 9, 10, 11, 12, 13, 14}};

int eq_array[DIM_FLAGS == 3];
int eq_source[DIM_FLAGS == 3] = {5};
int eq_grid[DIM_FLAGS == 3][2];
int eq_grid_source[DIM_FLAGS == 3][2] = {{5, 6}};

int sum_ints(const int *values, int count) {
  int sum = 0;
  int i;
  for (i = 0; i < count; i++)
    sum += values[i];
  return sum;
}

int and_array_sum(void) {
  return sum_ints(and_array, DIM_FLAGS & 6);
}

int and_grid_sum(void) {
  int sum = 0;
  int i;
  for (i = 0; i < (DIM_FLAGS & 6); i++)
    sum += sum_ints(and_grid[i], 2);
  return sum;
}

int xor_array_sum(void) {
  return sum_ints(xor_array, DIM_FLAGS ^ 4);
}

int xor_grid_sum(void) {
  return sum_ints(xor_grid[0], DIM_FLAGS ^ 4) + sum_ints(xor_grid[1], DIM_FLAGS ^ 4);
}

int eq_array_sum(void) {
  return sum_ints(eq_array, DIM_FLAGS == 3);
}

int eq_grid_sum(void) {
  return sum_ints(eq_grid[0], 2);
}

int or_array_sum(void) {
  int sum = 0;
  int i;
  for (i = 0; i < (DIM_FLAGS | 4); i++)
    sum += or_array[i];
  return sum;
}

int or_text_length(char text[DIM_FLAGS | 4]) {
  int n = 0;
  while (text[n])
    n++;
  return n;
}

int or_grid_sum(void) {
  int sum = 0;
  int i, j;
  for (i = 0; i < (DIM_FLAGS | 1); i++)
    for (j = 0; j < 2; j++)
      sum += or_grid[i][j];
  return sum;
}

typedef struct DimensionHolder {
  int or_member[DIM_FLAGS | 4];
  int or_grid_member[DIM_FLAGS | 1][2];
  char or_text_member[DIM_FLAGS | 4];
} DimensionHolder;

int or_member_sum(const DimensionHolder *holder) {
  int sum = 0;
  int i;
  for (i = 0; i < (DIM_FLAGS | 4); i++)
    sum += holder->or_member[i];
  return sum;
}

int or_grid_member_sum(const DimensionHolder *holder) {
  int sum = 0;
  int i, j;
  for (i = 0; i < (DIM_FLAGS | 1); i++)
    for (j = 0; j < 2; j++)
      sum += holder->or_grid_member[i][j];
  return sum;
}
%}
