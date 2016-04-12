#include <stdio.h>
#include <stdlib.h>

#include "char_strings/char_strings_wrap.h"

int main() {
  char *CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible.";
  char *OTHERLAND_MSG = "Little message from the safe world.";

  long count = 10000;
  long i = 0;

  // get functions
  for (i=0; i<count; i++) {
    char *str = GetCharHeapString();
    if (strcmp(str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test char get 1 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
    DeleteCharHeapString();
  }

  for (i=0; i<count; i++) {
    const char *str = GetConstCharProgramCodeString();
    if (strcmp(str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test char get 2 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
    DeleteCharHeapString();
  }

  for (i=0; i<count; i++) {
    char *str = GetCharStaticString();
    if (strcmp(str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test char get 3 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char *str = GetCharStaticStringFixed();
    if (strcmp(str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test char get 4 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  for (i=0; i<count; i++) {
    const char *str = GetConstCharStaticStringFixed();
    if (strcmp(str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test char get 5 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  // set functions
  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!SetCharHeapString(str, i)) {
      fprintf(stderr, "Test char set 1 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }


  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!SetCharStaticString(str, i)) {
      fprintf(stderr, "Test char set 2 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!SetCharArrayStaticString(str, i)) {
      fprintf(stderr, "Test char set 3 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!SetConstCharHeapString(str, i)) {
      fprintf(stderr, "Test char set 4 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!SetConstCharStaticString(str, i)) {
      fprintf(stderr, "Test char set 5 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!SetConstCharArrayStaticString(str, i)) {
      fprintf(stderr, "Test char set 6 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }
  
  // get set function
  for (i=0; i<count; i++) {
    char ping[256];
    sprintf(ping, "%s%d", OTHERLAND_MSG, i);
    char *pong = CharPingPong(ping);
    if (strcmp(ping, pong) != 0) {
      fprintf(stderr, "Test PingPong 1 failed.\nExpected:%d\nReceived:%d\n", ping, pong);
      SWIG_exit(1);
    }
  }

  // variables

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    global_char = str;
    if (strcmp(global_char, str) != 0) {
      fprintf(stderr, "Test variables 1 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    sprintf(global_char_array1, "%s%d", OTHERLAND_MSG, i);
    if (strcmp(global_char_array1, str) != 0) {
      fprintf(stderr, "Test variables 2 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    sprintf(global_char_array2, "%s%d", OTHERLAND_MSG, i);
    if (strcmp(global_char_array2, str) != 0) {
      fprintf(stderr, "Test variables 3 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  for (i=0; i<count; i++) {
    if (strcmp(global_const_char, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test variables 3 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  /*
  for (i=0; i<count; i++) {
    if (strcmp(global_const_char_array1, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test variables 5 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  for (i=0; i<count; i++) {
    if (strcmp(global_const_char_array2, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test variables 6 failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }
  */

  // char *& tests
  
  for (i=0; i<count; i++) {
    char **str = GetConstCharPointerRef();
    if (strcmp(*str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test char pointer ref get failed, iteration %d\n",i);
      SWIG_exit(1);
    }
  }
   
  for (i=0; i<count; i++) {
    char *str = (char*) malloc(sizeof(char) * 256);
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!SetConstCharPointerRef((char **) &str, i)) {
      fprintf(stderr, "Test char pointer ref set failed, iteration %d\n", i);
      SWIG_exit(1);
    }
  }

  SWIG_exit(0);
}

