%module grouping

%inline %{

int (test1)(int x) {
   return x;
}

int *(test2)(int x) {
    static int y;
    y = x;
    return &y;
}

%}

