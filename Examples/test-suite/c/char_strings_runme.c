#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "char_strings/char_strings_wrap.h"

int main() {
  const char *CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible.";
  const char *OTHERLAND_MSG = "Little message from the safe world.";

  int count = 10000;
  int i = 0;

  // get functions
  for (i=0; i<count; i++) {
    char *str = char_strings_GetCharHeapString();
    if (strcmp(str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test char get 1 failed, iteration %d\n", i);
      exit(1);
    }
    char_strings_DeleteCharHeapString();
  }

  for (i=0; i<count; i++) {
    const char *str = char_strings_GetConstCharProgramCodeString();
    if (strcmp(str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test char get 2 failed, iteration %d\n", i);
      exit(1);
    }
    char_strings_DeleteCharHeapString();
  }

  for (i=0; i<count; i++) {
    char *str = char_strings_GetCharStaticString();
    if (strcmp(str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test char get 3 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char *str = char_strings_GetCharStaticStringFixed();
    if (strcmp(str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test char get 4 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    const char *str = char_strings_GetConstCharStaticStringFixed();
    if (strcmp(str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test char get 5 failed, iteration %d\n", i);
      exit(1);
    }
  }

  // set functions
  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!char_strings_SetCharHeapString(str, i)) {
      fprintf(stderr, "Test char set 1 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!char_strings_SetCharStaticString(str, i)) {
      fprintf(stderr, "Test char set 2 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!char_strings_SetCharArrayStaticString(str, i)) {
      fprintf(stderr, "Test char set 3 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!char_strings_SetConstCharHeapString(str, i)) {
      fprintf(stderr, "Test char set 4 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!char_strings_SetConstCharStaticString(str, i)) {
      fprintf(stderr, "Test char set 5 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!char_strings_SetConstCharArrayStaticString(str, i)) {
      fprintf(stderr, "Test char set 6 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!char_strings_SetCharConstStaticString(str, i)) {
      fprintf(stderr, "Test char set 7 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!char_strings_SetConstCharConstStaticString(str, i)) {
      fprintf(stderr, "Test char set 8 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!char_strings_SetConstCharTypedefString(str, i)) {
      fprintf(stderr, "Test char set 9 failed, iteration %d\n", i);
      exit(1);
    }
  }

  // get set function
  for (i=0; i<count; i++) {
    char ping[256];
    sprintf(ping, "%s%d", OTHERLAND_MSG, i);
    char *pong = char_strings_CharPingPong(ping);
    if (strcmp(ping, pong) != 0) {
      fprintf(stderr, "Test PingPong 1 failed.\nExpected:%s\nReceived:%s\n", ping, pong);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char ping[256];
    sprintf(ping, "%s%d", OTHERLAND_MSG, i);
    char *pong = char_strings_CharArrayPingPong(ping);
    if (strcmp(ping, pong) != 0) {
      fprintf(stderr, "Test PingPong 2 failed.\nExpected:%s\nReceived:%s\n", ping, pong);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char ping[256];
    sprintf(ping, "%s%d", OTHERLAND_MSG, i);
    char *pong = char_strings_CharArrayDimsPingPong(ping);
    if (strcmp(ping, pong) != 0) {
      fprintf(stderr, "Test PingPong 3 failed.\nExpected:%s\nReceived:%s\n", ping, pong);
      exit(1);
    }
  }

  // variables
  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    char_strings_global_char_set(str);
    if (strcmp(char_strings_global_char_get(), str) != 0) {
      fprintf(stderr, "Test variables 1 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    char_strings_global_char_array1_set(str);
    if (strcmp(char_strings_global_char_array1_get(), str) != 0) {
      fprintf(stderr, "Test variables 2 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char str[256];
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    char_strings_global_char_array2_set(str);
    if (strcmp(char_strings_global_char_array2_get(), str) != 0) {
      fprintf(stderr, "Test variables 3 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    if (strcmp(char_strings_global_const_char_get(), CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test variables 4 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    if (strcmp(char_strings_global_const_char_array1_get(), CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test variables 5 failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    if (strcmp(char_strings_global_const_char_array2_get(), CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test variables 6 failed, iteration %d\n", i);
      exit(1);
    }
  }

  // char *& tests
  for (i=0; i<count; i++) {
    char **str = char_strings_GetCharPointerRef();
    if (strcmp(*str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test char pointer ref get failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char buf[256];
    char *str = buf;
    sprintf(str, "%s%d", OTHERLAND_MSG, i);
    if (!char_strings_SetCharPointerRef(&str, i)) {
      fprintf(stderr, "Test char pointer ref set failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    const char **str = char_strings_GetConstCharPointerRef();
    if (strcmp(*str, CPLUSPLUS_MSG) != 0) {
      fprintf(stderr, "Test const char pointer ref get failed, iteration %d\n", i);
      exit(1);
    }
  }

  for (i=0; i<count; i++) {
    char buf[256];
    const char *str = buf;
    sprintf(buf, "%s%d", OTHERLAND_MSG, i);
    if (!char_strings_SetConstCharPointerRef(&str, i)) {
      fprintf(stderr, "Test const char pointer ref set failed, iteration %d\n", i);
      exit(1);
    }
  }

  exit(0);
}
