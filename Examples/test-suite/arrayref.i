// A function that passes arrays by reference 

%module arrayref

%inline %{

void foo(const int (&x)[10]) {
}

void bar(int (&x)[10]) {
}

const char letters[4] = "abc";

// A reference to an array of const cannot be written through, so the variable is read only.
const char (&letters_ref)[4] = letters;
%}


