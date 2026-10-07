// A function that passes arrays by reference

%module arrayref

%{
#include <string.h>
%}

%inline %{

void foo(const int (&x)[10]) {
}

void bar(int (&x)[10]) {
}

int numbers[4] = {1, 2, 3, 4};
int others[4] = {10, 20, 30, 40};

// A variable that is a reference to an array is set by copying the elements of the array it refers
// to, as the array itself is, rather than by an array assignment, which does not compile.
int (&numbers_ref)[4] = numbers;

// A language that wraps an array of char as a string wraps a reference to one the same way.
char letters[4] = "abc";
char (&letters_ref)[4] = letters;

// A reference to an array of const cannot be written through, so the variable is read only, in the
// same way the array it refers to is.
const char frozen[4] = "xyz";
const char (&frozen_ref)[4] = frozen;

int (*others_address())[4] { return &others; }

int numbers_sum() {
  return numbers[0] + numbers[1] + numbers[2] + numbers[3];
}

const char *letters_are() { return letters; }

// An argument that is a reference to an array of char is a string too, but never null, as a reference cannot be.
int length_of(const char (&text)[8]) { return (int)strlen(text); }
int length_of_writable(char (&text)[8]) { return (int)strlen(text); }

struct ArrayRefMember {
  int backing[4];
  int (&member_ref)[4];
  char text[8];
  char (&text_ref)[8];
  ArrayRefMember() : member_ref(backing), text_ref(text) {
    for (int i = 0; i < 4; i++)
      backing[i] = i + 1;
    strcpy(text, "hi");
  }
  int sum() const {
    return backing[0] + backing[1] + backing[2] + backing[3];
  }
  const char *text_is() const { return text; }
};

// Setting a reference to an array of arrays copies every element, not only the first of each row.
typedef int Row[3];
int grid[2][3] = {{1, 2, 3}, {4, 5, 6}};
int other_grid[2][3] = {{10, 20, 30}, {40, 50, 60}};
int (&grid_ref)[2][3] = grid;

int (*other_grid_address())[2][3] { return &other_grid; }

int grid_element(int i, int j) { return grid[i][j]; }

struct GridRefMember {
  int backing[2][3];
  Row (&rows_ref)[2];
  GridRefMember() : rows_ref(backing) {
    for (int i = 0; i < 2; i++)
      for (int j = 0; j < 3; j++)
        backing[i][j] = 0;
  }
  int element(int i, int j) const { return backing[i][j]; }
};
%}

// Setting a reference to an array of pointers, which only a template can declare, copies the pointers.
%inline %{
template<typename T> struct RefArrayHolder {
  T backing[2];
  T (&elements_ref)[2];
  RefArrayHolder() : elements_ref(backing) {
    backing[0] = 0;
    backing[1] = 0;
  }
};

int *pointers[2] = {&numbers[0], &numbers[3]};

int *(*pointers_address())[2] { return &pointers; }

bool holds_pointers(const RefArrayHolder<int *> &holder) {
  return holder.backing[0] == pointers[0] && holder.backing[1] == pointers[1];
}
%}
%template(PointerRefArrayHolder) RefArrayHolder<int *>;
