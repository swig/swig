// Rvalue references to arrays, which are wrapped as references to arrays

%module cpp11_rvalue_reference_array

%warnfilter(SWIGWARN_TYPEMAP_VARIN_UNDEF) unsized_rref;                      /* Unable to set variable of type int (&&)[] */
%warnfilter(SWIGWARN_TYPEMAP_VARIN_UNDEF) RvalueRefArrayMember::unsized_rref; /* Unable to set variable of type int (&&)[] */

%{
#include <string.h>
#include <utility>
%}

%inline %{
int numbers[4] = {1, 2, 3, 4};
int others[4] = {10, 20, 30, 40};

int (*others_address())[4] { return &others; }
int (*others_unsized_address())[] { return reinterpret_cast<int (*)[]>(&others); }

int numbers_sum() { return numbers[0] + numbers[1] + numbers[2] + numbers[3]; }

int sum_of(int (&&x)[4]) { return x[0] + x[1] + x[2] + x[3]; }
int first_of(int (&&x)[]) { return x[0]; }

// An rvalue reference to an array of char is a string, as a reference to one is
int length_of(const char (&&text)[8]) { return (int)strlen(text); }
int length_of_writable(char (&&text)[8]) { return (int)strlen(text); }

struct RvalueRefArrayItem {
  int value;
};
RvalueRefArrayItem items[2] = {{1}, {2}};
RvalueRefArrayItem (*items_address())[2] { return &items; }
int items_sum(RvalueRefArrayItem (&&x)[2]) { return x[0].value + x[1].value; }

int (&&numbers_rref)[4] = std::move(numbers);
int (&&unsized_rref)[] = std::move(*reinterpret_cast<int (*)[]>(&numbers));

char letters[4] = "abc";
char (&&letters_rref)[4] = std::move(letters);
const char *letters_are() { return letters; }

struct RvalueRefArrayMember {
  int backing[4];
  int (&&member_rref)[4];
  int (&&unsized_rref)[];
  char text[8];
  char (&&text_rref)[8];
  RvalueRefArrayMember() : backing(), member_rref(std::move(backing)),
      unsized_rref(std::move(*reinterpret_cast<int (*)[]>(&backing))), text(), text_rref(std::move(text)) {
    for (int i = 0; i < 4; i++)
      backing[i] = i + 1;
    strcpy(text, "hi");
  }
  int sum() const {
    return backing[0] + backing[1] + backing[2] + backing[3];
  }
  const char *text_is() const { return text; }
};
%}
