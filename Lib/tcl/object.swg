/* object.swg
 *
 * Tcl8.x - Object oriented runtime functions
 */

typedef int (*_swig_wrapper)(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

typedef struct _swig_method { 
  const char     *name;
  _swig_wrapper   method;
} _swig_method;

typedef struct _swig_attribute {
  const char     *name;
  _swig_wrapper   getmethod;
  _swig_wrapper   setmethod;
} _swig_attribute;
  
typedef struct _swig_class {
  const char        *name;
  _swig_type_info  **type;
  _swig_wrapper      constructor;
  void             (*destructor)(void *);
  _swig_method      *methods;
  _swig_attribute   *attributes;
} _swig_class;

typedef struct _swig_instance {
  Tcl_Obj       *thisptr;
  void          *thisvalue;
  _swig_class   *classptr;
  int            destroy;
} _swig_instance;

static void SwigObjectDelete(ClientData clientData) {
  _swig_instance *si = (_swig_instance *) clientData;
  if (si->destroy) {
    if (si->classptr->destructor) {
      (si->classptr->destructor)(si->thisvalue);
    }
  }
  Tcl_DecrRefCount(si->thisptr);
  free(si);
}

/* Function to invoke object methods given an instance */
static int
SwigMethodCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST _objv[])
{
  char *method, *attrname;
  _swig_instance  *inst = (_swig_instance *) clientData;
  _swig_method    *meth;
  _swig_attribute *attr;
  Tcl_Obj         *oldarg;
  Tcl_Obj         **objv;
  int              rcode;

  objv = (Tcl_Obj **) _objv;
  if (objc < 2) {
    Tcl_SetResult(interp,"wrong # args.", TCL_STATIC);
    return TCL_ERROR;
  }
  meth = inst->classptr->methods;
  method = Tcl_GetStringFromObj(objv[1],NULL);

  /* Check for methods */
  while (meth && meth->name) {
    if (strcmp(meth->name,method) == 0) {
      oldarg = objv[1];
      objv[1] = inst->thisptr;
      Tcl_IncrRefCount(inst->thisptr);
      rcode = (*meth->method)(clientData,interp,objc,objv);
      objv[1] = oldarg;
      Tcl_DecrRefCount(inst->thisptr);
      return rcode;
    }
    meth++;
  }
  /* Check class methods for a match */
  if (strcmp(method,"cget") == 0) {
    if (objc < 3) {
      Tcl_SetResult(interp,"wrong # args.", TCL_STATIC);
      return TCL_ERROR;
    }
    attrname = Tcl_GetStringFromObj(objv[2],NULL);
    attr = inst->classptr->attributes;
    while (attr && attr->name) {
      if ((strcmp(attr->name, attrname) == 0) && (attr->getmethod)) {
	oldarg = objv[1];
	objv[1] = inst->thisptr;
	Tcl_IncrRefCount(inst->thisptr);
	rcode = (*attr->getmethod)(clientData,interp,2, objv);
	objv[1] = oldarg;
	Tcl_DecrRefCount(inst->thisptr);
	return rcode;
      }
      attr++;
    }
    if (strcmp(attrname, "-this") == 0) {
      Tcl_SetObjResult(interp, Tcl_DuplicateObj(inst->thisptr));
      return TCL_OK;
    }
    Tcl_SetResult(interp,"Invalid attribute.", TCL_STATIC);
    return TCL_ERROR;
  } else if (strcmp(method, "configure") == 0) {
    int i;
    if (objc < 4) {
      Tcl_SetResult(interp,"wrong # args.", TCL_STATIC);
      return TCL_ERROR;
    }
    i = 2;
    while (i < objc) {
      attrname = Tcl_GetStringFromObj(objv[i],NULL);
      attr = inst->classptr->attributes;
      while (attr && attr->name) {
	if ((strcmp(attr->name, attrname) == 0) && (attr->setmethod)) {
	  oldarg = objv[i];
	  objv[i] = inst->thisptr;
	  Tcl_IncrRefCount(inst->thisptr);
	  rcode = (*attr->setmethod)(clientData,interp,3, &objv[i-1]);
	  objv[i] = oldarg;
	  Tcl_DecrRefCount(inst->thisptr);
	  if (rcode != TCL_OK) return rcode;
	  i+=2;
	  break;
	}
	attr++;
      }
      if (inst->classptr->attributes && !(attr->name)) {
	Tcl_SetResult(interp,"Invalid attribute name.", TCL_STATIC);
	return TCL_ERROR;
      }
    }
    return TCL_OK;
  } else {
    Tcl_SetResult(interp,"Invalid method. Must be one of: configure cget ", TCL_STATIC);
    meth = inst->classptr->methods;
    while (meth && meth->name) {
      Tcl_AppendElement(interp, meth->name);
      meth++;
    }
    return TCL_ERROR;
  }

  
}

/* Function to create objects */
static int 
SwigObjectCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
    Tcl_Obj          *newObj = 0;
    void             *thisvalue = 0;
    _swig_instance   *newinst = 0;
    _swig_class      *classptr = (_swig_class *) clientData;
    _swig_wrapper     cons = 0;
    char             *name = 0;
    int               firstarg = 0;
    int               thisarg = 0;
    int               destroy = 1; 
    Tcl_CmdInfo       ci;

    if (!classptr) {
      Tcl_SetResult(interp,"swig: internal runtime error. No class object defined.", TCL_STATIC);
      return TCL_ERROR;
    }
    cons = classptr->constructor;
    if (objc > 1) {
      char *s = Tcl_GetStringFromObj(objv[1],NULL);
      if (strcmp(s,"-this") == 0) {
	thisarg = 2;
	cons = 0;
      } else if (strcmp(s,"-args") == 0) {
	firstarg = 1;
      } else if (objc == 2) {
	firstarg = 1;
	name = s;
      } else if (objc >= 3) {
	char *s1;
	name = s;
	s1 = Tcl_GetStringFromObj(objv[2],NULL);
	if (strcmp(s1,"-this") == 0) {
	  thisarg = 3;
	  cons = 0;
	} else {
	  firstarg = 1;
	}
      }
    }
    if (cons) {
      int result;
      result = (*cons)(0, interp, objc-firstarg, &objv[firstarg]);
      if (result != TCL_OK) {
	return result;
      }
      newObj = Tcl_DuplicateObj(Tcl_GetObjResult(interp));
      if (!name) name = Tcl_GetStringFromObj(newObj,NULL);
    } else if (thisarg > 0) {
      if (thisarg < objc) {
	destroy = 0;
	newObj = Tcl_DuplicateObj(objv[thisarg]);
	if (!name) name = Tcl_GetStringFromObj(newObj,NULL);
      } else {
	Tcl_SetResult(interp,"wrong # args.", TCL_STATIC);
	return TCL_ERROR;
      }
    } else {
      Tcl_SetResult(interp,"No constructor available.", TCL_STATIC);
      return TCL_ERROR;
    }
    if (!Tcl_GetCommandInfo(interp,name,&ci)) {
      if (SWIG_ConvertPtr(interp,newObj, (void **) &thisvalue, *(classptr->type)) == TCL_ERROR) {
	Tcl_DecrRefCount(newObj);
	return TCL_ERROR;
      }
      newinst = (_swig_instance *) malloc(sizeof(_swig_instance));
      newinst->thisptr = newObj;
      Tcl_IncrRefCount(newObj);
      newinst->thisvalue = thisvalue;
      newinst->classptr = classptr;
      newinst->destroy = destroy;
      Tcl_CreateObjCommand(interp,name, SwigMethodCmd, (ClientData) newinst, SwigObjectDelete);
      return TCL_OK;
    } else {
      Tcl_SetResult(interp,"Object name already exists!", TCL_STATIC);
      return TCL_ERROR;
    }
}

