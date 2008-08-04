#define CINTERFACE
#include <stdio.h>
#include <windows.h>
#include <initguid.h>
#include "virtual_poly/virtual_poly_generated.h"

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
  virtual_poly *vp = NULL;
  NDouble *d = NULL;
  NInt *i = NULL;
  NNumber *dc_as_nnumber = NULL;
  NDouble *dc = NULL;
  NNumber *ic_as_nnumber = NULL;
  NInt *ic = NULL;
  NDouble *ddc = NULL;
  NInt *dic = NULL;
  NNumber *n1 = NULL;
  NNumber *n2 = NULL;
  NDouble *dn1 = NULL;
  NDouble *dn2 = NULL;
  NNumber *nr = NULL;
  NDouble *dr1 = NULL;
  NNumber *dr2_as_nnumber = NULL;
  NDouble *dr2 = NULL;
  NInt *ic_temp = NULL;
  int temp1;
  int temp2;
  double dtemp1;
  double dtemp2;

  CoInitialize(NULL);

  CoCreateInstance(&CLSID_virtual_polyImpl, NULL, CLSCTX_INPROC_SERVER, &IID_virtual_poly, (void **) &vp);

  vp->lpVtbl->new_NDouble(vp, 3.5, &d);
  vp->lpVtbl->new_NInt(vp, 2, &i);

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

  dc_as_nnumber->lpVtbl->QueryInterface(dc_as_nnumber, &IID_NDouble, (void **) &dc);

  i->lpVtbl->copy(i, &ic_as_nnumber);

  ic_as_nnumber->lpVtbl->QueryInterface(ic_as_nnumber, &IID_NInt, (void **) &ic);

  /*
   * Static methods
   */

  dc->lpVtbl->narrow(dc, dc_as_nnumber, &ddc);

  ic->lpVtbl->narrow(ic, ic_as_nnumber, &dic);

  dc_as_nnumber->lpVtbl->Release(dc_as_nnumber);
  ic_as_nnumber->lpVtbl->Release(ic_as_nnumber);
  dc->lpVtbl->Release(dc);
  ic->lpVtbl->Release(ic);

  ic = dic;
  dc = ddc;

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

  /*
   * Checking a pure user downcast
   */
  d->lpVtbl->copy(d, &n1);
  d->lpVtbl->nnumber(d, &n2);
  d->lpVtbl->narrow(d, n1, &dn1);
  d->lpVtbl->narrow(d, n2, &dn2);

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
  d->lpVtbl->narrow(d, nr, &dr1);
  d->lpVtbl->ref_this(d, &dr2_as_nnumber);

  dr2_as_nnumber->lpVtbl->QueryInterface(dr2_as_nnumber, &IID_NDouble, (void **) &dr2);

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

  return 0;
}
