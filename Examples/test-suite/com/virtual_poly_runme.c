#define CINTERFACE
#include <stdio.h>
#include <windows.h>

#ifndef MSVC
/* This is a workaround for a VC specific attribute */
#define __RPC__deref_out
#endif

#ifdef __DMC__
#define __RPCNDR_H_VERSION__        ( 450 ) 
#endif

#include "virtual_poly/virtual_poly_generated.h"

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
  Ivirtual_poly *vp = NULL;
  INDoubleStatic *nds = NULL;
  INIntStatic *nis = NULL;
  INDouble *d = NULL;
  INInt *i = NULL;
  INNumber *dc_as_nnumber = NULL;
  INDouble *dc = NULL;
  INNumber *ic_as_nnumber = NULL;
  INInt *ic = NULL;
  INDouble *ddc = NULL;
  INInt *dic = NULL;
  INNumber *n1 = NULL;
  INNumber *n2 = NULL;
  INDouble *dn1 = NULL;
  INDouble *dn2 = NULL;
  INNumber *nr = NULL;
  INDouble *dr1 = NULL;
  INNumber *dr2_as_nnumber = NULL;
  INDouble *dr2 = NULL;
  INInt *ic_temp = NULL;
  int temp1;
  int temp2;
  double dtemp1;
  double dtemp2;

  CoInitialize(NULL);

  CoCreateInstance(&CLSID_virtual_polyImpl, NULL, CLSCTX_INPROC_SERVER, &IID_Ivirtual_poly, (void **) &vp);

  /* Objects containing NDouble and NInt static methods (including constructors) */
  vp->lpVtbl->get_NDouble(vp, &nds);
  vp->lpVtbl->get_NInt(vp, &nis);

  /* Constructor calls */
  nds->lpVtbl->new_NDouble(nds, 3.5, &d);
  nis->lpVtbl->new_NInt(nis, 2, &i);

  /*
   * These two natural 'copy' forms fail because no covariant (polymorphic) return types 
   * are supported in C#. 
   *
   * NDouble dc = d.copy();
   * NInt ic = i.copy();
   *
   *
   * Unlike C++, we have to downcast instead.
   */

  d->lpVtbl->copy(d, &dc_as_nnumber);

  dc_as_nnumber->lpVtbl->QueryInterface(dc_as_nnumber, &IID_INDouble, (void **) &dc);

  i->lpVtbl->copy(i, &ic_as_nnumber);

  ic_as_nnumber->lpVtbl->QueryInterface(ic_as_nnumber, &IID_INInt, (void **) &ic);

  /*
   * Static methods
   */

  /* Called from the 'static class' object */
  nds->lpVtbl->narrow(nds, dc_as_nnumber, &ddc);

  /* Called from the object */
  ic->lpVtbl->narrow(ic, ic_as_nnumber, &dic);

  dc_as_nnumber->lpVtbl->Release(dc_as_nnumber);
  ic_as_nnumber->lpVtbl->Release(ic_as_nnumber);

  vp->lpVtbl->incr(vp, ic, &ic_temp);
  ic_temp->lpVtbl->Release(ic_temp);

  i->lpVtbl->get(i, &temp1);
  ic->lpVtbl->get(ic, &temp2);

  if (temp1 + 1 != temp2) {
    fprintf(stderr, "incr test failed\n");
    exit(1);
  }

  dc->lpVtbl->Release(dc);
  ic->lpVtbl->Release(ic);
  dic->lpVtbl->Release(dic);
  ddc->lpVtbl->Release(ddc);

  /*
   * Checking a pure user downcast
   */
  d->lpVtbl->copy(d, &n1);
  d->lpVtbl->nnumber(d, &n2);
  nds->lpVtbl->narrow(nds, n1, &dn1);
  nds->lpVtbl->narrow(nds, n2, &dn2);

  dn1->lpVtbl->get(dn1, &dtemp1);
  dn2->lpVtbl->get(dn2, &dtemp2);

  if (dtemp1 != dtemp2) {
    fprintf(stderr, "copy/narrow test failed\n");
    exit(1);
  }

  n1->lpVtbl->Release(n1);
  n2->lpVtbl->Release(n2);
  dn1->lpVtbl->Release(dn1);
  dn2->lpVtbl->Release(dn2);

  /*
   * Checking the ref polymorphic case
   */
  d->lpVtbl->ref_this(d, &nr);
  nds->lpVtbl->narrow(nds, nr, &dr1);
  d->lpVtbl->ref_this(d, &dr2_as_nnumber);

  dr2_as_nnumber->lpVtbl->QueryInterface(dr2_as_nnumber, &IID_INDouble, (void **) &dr2);

  dr1->lpVtbl->get(dr1, &dtemp1);
  dr2->lpVtbl->get(dr2, &dtemp2);

  if (dtemp1 != dtemp2) {
    fprintf(stderr, "copy/narrow test failed\n");
    exit(1);
  }

  nr->lpVtbl->Release(nr);
  dr1->lpVtbl->Release(dr1);
  dr2_as_nnumber->lpVtbl->Release(dr2_as_nnumber);
  dr2->lpVtbl->Release(dr2);

  i->lpVtbl->Release(i);
  d->lpVtbl->Release(d);

  vp->lpVtbl->Release(vp);

  CoUninitialize();

  return 0;
}
