%module lib_typemaps

%include "typemaps.i"

%inline %{

int in_int(int *INPUT) { return *INPUT; }
long in_long(long *INPUT) { return *INPUT; }
short in_short(short *INPUT) { return *INPUT; }
unsigned int in_uint(unsigned int *INPUT) { return *INPUT; }
unsigned short in_ushort(unsigned short *INPUT) { return *INPUT; }
unsigned long in_ulong(unsigned long *INPUT) { return *INPUT; }
unsigned char in_uchar(unsigned char *INPUT) { return *INPUT; }
signed char in_schar(signed char *INPUT) { return *INPUT; }
float in_float(float *INPUT) { return *INPUT; }
double in_double(double *INPUT) { return *INPUT; }

void out_int(int x, int *OUTPUT) {  *OUTPUT = x; }
void out_short(short x, short *OUTPUT) {  *OUTPUT = x; }
void out_long(long x, long *OUTPUT) {  *OUTPUT = x; }
void out_uint(unsigned int x, unsigned int *OUTPUT) {  *OUTPUT = x; }
void out_ushort(unsigned short x, unsigned short *OUTPUT) {  *OUTPUT = x; }
void out_ulong(unsigned long x, unsigned long *OUTPUT) {  *OUTPUT = x; }
void out_uchar(unsigned char x, unsigned char *OUTPUT) {  *OUTPUT = x; }
void out_schar(signed char x, signed char *OUTPUT) {  *OUTPUT = x; }
void out_float(float x, float *OUTPUT) {  *OUTPUT = x; }
void out_double(double x, double *OUTPUT) {  *OUTPUT = x; }

void inout_int(int *INOUT) {  *INOUT = *INOUT; }
void inout_short(short *INOUT) {  *INOUT = *INOUT; }
void inout_long(long *INOUT) {  *INOUT = *INOUT; }
void inout_uint(unsigned int *INOUT) {  *INOUT = *INOUT; }
void inout_ushort(unsigned short *INOUT) {  *INOUT = *INOUT; }
void inout_ulong(unsigned long *INOUT) {  *INOUT = *INOUT; }
void inout_uchar(unsigned char *INOUT) {  *INOUT = *INOUT; }
void inout_schar(signed char *INOUT) {  *INOUT = *INOUT; }
void inout_float(float *INOUT) {  *INOUT = *INOUT; }
void inout_double(double *INOUT) {  *INOUT = *INOUT; }

%}




