%module li_cstring

%include "cstring.i"

#ifndef _CSTRING_UNIMPL

%cstring_input_binary(char *in, int n);
%cstring_bounded_output(char *out1, 512);
%cstring_chunk_output(char *out2, 128);
%cstring_bounded_mutable(char *out3, 512);
%cstring_mutable(char *out4, 32);
%cstring_output_maxsize(char *out5, int max);
%cstring_output_withsize(char *out6, int *size);
%cstring_output_allocate(char **out7, delete [] $1);
%cstring_output_allocate_size(char **out8, int *size, delete [] $1);

%inline %{

int count(char *in, int n, char c) {
   int r = 0;
   while (n > 0) {
     if (*in == c) {
	r++;
     }
     in++;
   }
   return r;
}

void test1(char *out1) {
   strcpy(out1,"Hello World");
}

void test2(char *out2) {
   int i;
   for (i = 0; i < 128; i++) {
       *out2 = (char) i;
       out2++;
   }
}

void test3(char *out3) {
   strcat(out3,"-suffix");
}

void test4(char *out4) {
   strcat(out4,"-suffix");
}

void test5(char *out5, int max) {
   int i;
   for (i = strlen(out5); i < max; i++) {
       out5[i] = 'x';
   }
}

void test6(char *out6, int *size) {
   int i;
   for (i = 0; i < (*size/2); i++) {
       out6[i] = 'x';
   }
   *size = (*size/2);
}

void test7(char **out7) {
   *out7 = new char[64];
   strcat(*out7,"Hello world!");
}

void test8(char **out8, int *sz) {
   int i;
   *out8 = new char[128];
   for (i = 0; i < 128; i++) {
      *out8[i] = (char) i;
   }
}

%}

#endif
  
    




      
    
