/* -*- c -*- */

%module test

%include "list-vector.i"

double sum_list(int LISTLENINPUT, double *LISTINPUT);
double sum_vector(int VECTORLENINPUT, double *VECTORINPUT);
void one_to_seven_list(int *LISTLENOUTPUT, int **LISTOUTPUT);
void one_to_seven_vector(int *VECTORLENOUTPUT, int **VECTOROUTPUT);

%{
  double sum_list(int length, double *item)
  {
    int i;
    double res = 0.0;
    for (i = 0; i<length; i++)
      res += item[i];
    return res;
  }

  double sum_vector(int length, double *item)
  {
    int i;
    double res = 0.0;
    for (i = 0; i<length; i++)
      res += item[i];
    return res;
  }

  void one_to_seven_list(int *length_p, int **list_p)
  {
    int i;
    *length_p = 7;
    *list_p = malloc(7 * sizeof(int));
    for (i = 0; i<7; i++)
      (*list_p)[i] = i+1;
  }

  void one_to_seven_vector(int *length_p, int **list_p)
  {
    int i;
    *length_p = 7;
    *list_p = malloc(7 * sizeof(int));
    for (i = 0; i<7; i++)
      (*list_p)[i] = i+1;
  }

%}
