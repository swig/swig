%module file_test

%include file.i


%inline 
%{
  int nfile(FILE *file) {
    printf("hello %p\n", (void*)file);
    if (file) {
      // fprintf(file,"hello\n");
    }
    return 0;
  }

  int nfile(const char *filename) {
    FILE *file = fopen(filename,"w");
    nfile(file);
    fclose(file);
    return 0;
  }

  FILE* GetStdOut() {
    return stdout;
  }
  
%}

