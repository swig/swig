/* File : example.i */
%module example

%{
#include <string.h>

typedef struct point {
  int x;
  int y;
} Point;


Point *point_create(int x, int y) {
  Point *p = (Point *) malloc(sizeof(Point));
  p->x = x;
  p->y = y;

  return p;
}

/* this function will be wrapped by jswig */
char *point_toString1(Point *p) {
  char buf[80];

  sprintf(buf, "(%d,%d)", p->x, p->y);

  return strdup(buf); /* memory leak */
}

/* this one we wrapped manually*/
JNIEXPORT jstring JNICALL Java_example_point_1toString2(JNIEnv *jenv, jclass jcls, jlong jpoint) {
    Point * p;
    char buf[80];
    jstring result;

    p = *(Point **)&jpoint;
    sprintf(buf, "[%d,%d]", p->x, p->y);

    result = (*jenv)->NewStringUTF(jenv, buf);

    return result;
}
%}


Point *point_create(int x, int y);
char *point_toString1(Point *p);
/*
  Use %new to free the memory returned by point_toString1

  %new char *point_toString1(Point *p);
*/

%native(point_toString2) char *point_toString2(Point *p);
