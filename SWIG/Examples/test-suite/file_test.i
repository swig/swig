%module file_test

%include file.i


%inline 
%{
  int nfile(FILE *file) {
    return 0;
  }

  int nfile_name(const char *filename) {
    FILE *file = fopen(filename,"w");
    nfile(file);
    fclose(file);
    return 0;
  }

  FILE* GetStdOut() {
    return stdout;
  }
  
%}

