%module arrays_null

#ifdef SWIGC
// TODO: arrays of classes and references to arrays do not compile in the C target language
%ignore ArraysNull::items;
%ignore arrays_null_items;
%ignore arrays_null_ints_ref;
#endif

// Setting an array member or global variable to NULL is an error, as there is nothing to copy from
%inline %{
struct ArraysNullItem {
  int value;
};

struct ArraysNull {
  int ints[4];
  ArraysNullItem items[2];
  int grid[2][3];
};

void arrays_null_fill(ArraysNull *s, int start) {
  int i;
  for (i = 0; i < 4; i++)
    s->ints[i] = start + i;
  for (i = 0; i < 2; i++)
    s->items[i].value = start + i;
  for (i = 0; i < 6; i++)
    s->grid[i / 3][i % 3] = start + i;
}

int arrays_null_check(const ArraysNull *s, int start) {
  int i;
  for (i = 0; i < 4; i++)
    if (s->ints[i] != start + i)
      return 0;
  for (i = 0; i < 2; i++)
    if (s->items[i].value != start + i)
      return 0;
  for (i = 0; i < 6; i++)
    if (s->grid[i / 3][i % 3] != start + i)
      return 0;
  return 1;
}

int arrays_null_ints[4];
ArraysNullItem arrays_null_items[2];
int arrays_null_grid[2][3];
int (&arrays_null_ints_ref)[4] = arrays_null_ints;

int arrays_null_globals_check(int start) {
  ArraysNull s;
  int i;
  for (i = 0; i < 4; i++)
    s.ints[i] = arrays_null_ints[i];
  for (i = 0; i < 2; i++)
    s.items[i] = arrays_null_items[i];
  for (i = 0; i < 6; i++)
    s.grid[i / 3][i % 3] = arrays_null_grid[i / 3][i % 3];
  return arrays_null_check(&s, start);
}

// NULL is still passed on as a NULL pointer for an array parameter
int arrays_null_isnull(int a[4]) {
  return a == 0;
}
%}
