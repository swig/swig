/* File: example.h */

typedef struct {
  int x,y;
} Point;

/* Some global variable declarations */
extern int              ivar;
extern short            svar;
extern long             lvar;
extern unsigned int     uivar;
extern unsigned short   usvar;
extern unsigned long    ulvar;
extern signed char      scvar;
extern unsigned char    ucvar;
extern char             cvar;
extern float            fvar;
extern double           dvar;
extern char            *strvar;
extern const char       cstrvar[];
extern int             *iptrvar;
extern char             name[5];

extern Point           *ptptr;
extern Point            pt;

extern int  status;
extern char path[256];

