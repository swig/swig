#include <mex.h> 
#include <sci_gateway.h>
#include <api_scilab.h>
#include <MALLOC.h>
static int direct_gateway(char *fname,void F(void)) { F();return 0;};
extern Gatefunc _wrap_nlopt_doublevector_empty;
extern Gatefunc _wrap_nlopt_doublevector_size;
extern Gatefunc _wrap_nlopt_doublevector_clear;
extern Gatefunc _wrap_nlopt_doublevector_swap;
extern Gatefunc _wrap_nlopt_doublevector_get_allocator;
extern Gatefunc _wrap_nlopt_doublevector_pop_back;
extern Gatefunc _wrap_new_nlopt_doublevector;
extern Gatefunc _wrap_nlopt_doublevector_push_back;
extern Gatefunc _wrap_nlopt_doublevector_front;
extern Gatefunc _wrap_nlopt_doublevector_back;
extern Gatefunc _wrap_nlopt_doublevector_assign;
extern Gatefunc _wrap_nlopt_doublevector_resize;
extern Gatefunc _wrap_nlopt_doublevector_reserve;
extern Gatefunc _wrap_nlopt_doublevector_capacity;
extern Gatefunc _wrap_delete_nlopt_doublevector;
extern Gatefunc _wrap_opt_set_lower_bound;
extern Gatefunc _wrap_new_opt;
extern Gatefunc _wrap_delete_opt;
static GenericTable Tab[]={
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_empty,"nlopt_doublevector_empty"},
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_size,"nlopt_doublevector_size"},
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_clear,"nlopt_doublevector_clear"},
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_swap,"nlopt_doublevector_swap"},
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_get_allocator,"nlopt_doublevector_get_allocator"},
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_pop_back,"nlopt_doublevector_pop_back"},
  {(Myinterfun)sci_gateway,_wrap_new_nlopt_doublevector,"new_nlopt_doublevector"},
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_push_back,"nlopt_doublevector_push_back"},
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_front,"nlopt_doublevector_front"},
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_back,"nlopt_doublevector_back"},
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_assign,"nlopt_doublevector_assign"},
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_resize,"nlopt_doublevector_resize"},
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_reserve,"nlopt_doublevector_reserve"},
  {(Myinterfun)sci_gateway,_wrap_nlopt_doublevector_capacity,"nlopt_doublevector_capacity"},
  {(Myinterfun)sci_gateway,_wrap_delete_nlopt_doublevector,"delete_nlopt_doublevector"},
  {(Myinterfun)sci_gateway,_wrap_opt_set_lower_bound,"opt_set_lower_bound"},
  {(Myinterfun)sci_gateway,_wrap_new_opt,"new_opt"},
  {(Myinterfun)sci_gateway,_wrap_delete_opt,"delete_opt"},
};
 
int C2F(libexamplelib)()
{
  Rhs = Max(0, Rhs);
  if (*(Tab[Fin-1].f) != NULL) 
  {
     if(pvApiCtx == NULL)
     {
       pvApiCtx = (StrCtx*)MALLOC(sizeof(StrCtx));
     }
     pvApiCtx->pstName = (char*)Tab[Fin-1].name;
    (*(Tab[Fin-1].f))(Tab[Fin-1].name,Tab[Fin-1].F);
  }
  return 0;
}
