//
// octrunfunc.swg - Octave runtime functions
//

SWIGOCTRT bool SWIG_Octave_CheckNumArgs(const char* func_name, int num_args, int max_args, int min_args, int varargs)
{
  if (num_args > max_args && !varargs) {
    error("function %s takes at most %i arguments", func_name, max_args);
  } else if (num_args < min_args) {
    error("function %s requires at least %i arguments", func_name, min_args);
  } else {
    return true;
  }
  return false;
}

SWIGOCTRT octave_value_list* SWIG_Octave_AppendOutput(octave_value_list* ovl, const octave_value& ov)
{
  ovl->append(ov);
  return ovl;
}

SWIGOCTRT octave_value SWIG_ErrorType(int code)
{
  switch (code) {
  case SWIG_MemoryError:
    return "SWIG_MemoryError";
  case SWIG_IOError:
    return "SWIG_IOError";
  case SWIG_RuntimeError:
    return "SWIG_RuntimeError";
  case SWIG_IndexError:
    return "SWIG_IndexError";
  case SWIG_TypeError:
    return "SWIG_TypeError";
  case SWIG_DivisionByZero:
    return "SWIG_DivisionByZero";
  case SWIG_OverflowError:
    return "SWIG_OverflowError";
  case SWIG_SyntaxError:
    return "SWIG_SyntaxError";
  case SWIG_ValueError:
    return "SWIG_ValueError";
  case SWIG_SystemError:
    return "SWIG_SystemError";
  case SWIG_AttributeError:
    return "SWIG_AttributeError";
  }
  return "SWIG unknown error";
}

SWIGOCTRT octave_value SWIG_Error(int code, const char* msg)
{
  octave_value type(SWIG_ErrorType(code));
  std::string r = msg;
  r += " (" + type.string_value() + ")";
  error(r.c_str());
  return octave_value(r);
}

SWIGOCTRT octave_value SWIG_Octave_NewPointerObj(void* ptr, swig_type_info* type, int flags)
{
  int own = (flags & SWIG_POINTER_OWN) ? SWIG_POINTER_OWN : 0;
#ifdef SWIG_DIRECTORS
  Swig::Director* d = Swig::get_rtdir(ptr);
  if (d && Swig::swig_director_get_self(d)) {
    return Swig::swig_director_get_self(d)->as_value();
  }
#endif
  return SWIG_Octave_ValueRef(new SwigOctType(ptr, type, own));
}

SWIGOCTRT int SWIG_Octave_ConvertPtrAndOwn(octave_value ov, void** ptr, swig_type_info* type, int flags, int* own)
{
  if (ov.is_cell() && ov.rows() == 1 && ov.columns() == 1) {
    ov = ov.cell_value()(0);
  }
  if (!ov.is_defined() || (ov.is_matrix_type() && ov.rows() == 0 && ov.columns() == 0)) {
    if (ptr) {
      *ptr = 0;
    }
    return SWIG_OK;
  }
  if (ov.type_id() != SwigOctRef::static_type_id()) {
    return SWIG_ERROR;
  }
  SwigOctRef* osr = static_cast < SwigOctRef*>(ov.internal_rep());
  SwigOctType* ost = osr->get_ptr();
  void* vptr = ost->cast(type, own, flags);
  if (!vptr) {
    return SWIG_ERROR;
  }
  if (ptr) {
    *ptr = vptr;
  }
  return SWIG_OK;
}

SWIGOCTRT octave_value SWIG_Octave_NewPackedObj(void* ptr, size_t sz, swig_type_info* type)
{
  return new SwigOctPacked(type, (char*) ptr, sz);
}

SWIGOCTRT int SWIG_Octave_ConvertPacked(const octave_value& ov, void* ptr, size_t sz, swig_type_info* type)
{
  if (!ov.is_defined()) {
    return SWIG_ERROR;
  }
  if (ov.type_id() != SwigOctPacked::static_type_id()) {
    return SWIG_ERROR;
  }
  SwigOctPacked* ost = static_cast < SwigOctPacked*>(ov.internal_rep());
  return ost->copy(type, (char*) ptr, sz) ? SWIG_OK : SWIG_ERROR;
}

SWIGOCTRTINLINE void SWIG_Octave_SetConstant(SwigOctType* module_ns, const std::string& name, const octave_value& ov)
{
  module_ns->assign(name, ov);
}

SWIGOCTRTINLINE octave_value SWIG_Octave_GetGlobalValue(std::string name)
{
  return get_global_value(name, true);
}

SWIGOCTRT void SWIG_Octave_SetGlobalValue(std::string name, const octave_value& value)
{
  set_global_value(name, value);
}

SWIGOCTRT void SWIG_Octave_LinkGlobalValue(std::string name)
{
#if !SWIG_OCTAVE_PREREQ(3,2,0)
  link_to_global_variable(curr_sym_tab->lookup(name, true));
#else
#if !SWIG_OCTAVE_PREREQ(3,8,0)
  symbol_table::varref(name);
#endif
  symbol_table::mark_global(name);
#endif
}

SWIGOCTRT swig_module_info* SWIG_Octave_GetModule(void* clientdata)
{
  octave_value ov = SWIG_Octave_GetGlobalValue("__SWIG_MODULE__" SWIG_TYPE_TABLE_NAME SWIG_RUNTIME_VERSION);
  if (!ov.is_defined() || ov.type_id() != SwigOctPacked::static_type_id()) {
    return 0;
  }
  const SwigOctPacked* osp = static_cast < const SwigOctPacked*>(ov.internal_rep());
  swig_module_info* pointer = 0;
  osp->copy(0, &pointer, sizeof(swig_module_info*));
  return pointer;
}

SWIGOCTRT void SWIG_Octave_SetModule(void* clientdata, swig_module_info* pointer)
{
  octave_value ov = new SwigOctPacked(0, &pointer, sizeof(swig_module_info*));
  SWIG_Octave_SetGlobalValue("__SWIG_MODULE__" SWIG_TYPE_TABLE_NAME SWIG_RUNTIME_VERSION, ov);
}

SWIGOCTRT octave_base_value* SWIG_Octave_ValueRef(SwigOctType* ost)
{
  return new SwigOctRef(ost);
}

SWIGOCTRT SwigOctType* SWIG_Octave_ValueDeref(octave_value ov)
{
  if (ov.is_cell() && ov.rows() == 1 && ov.columns() == 1) {
    ov = ov.cell_value()(0);
  }
  return SWIG_Octave_ValueDeref(*ov.internal_rep());
}

SWIGOCTRT SwigOctType* SWIG_Octave_ValueDeref(const octave_base_value& ov)
{
  if (ov.type_id() != SwigOctRef::static_type_id()) {
    return 0;
  }
  const SwigOctRef* osr = static_cast < const SwigOctRef*>(&ov);
  return osr->get_ptr();
}

SWIGOCTRT octave_value_list SWIG_Octave_SetImmutable(const octave_value_list& args, int nargout)
{
  error("attempt to set immutable member variable");
  return octave_value_list();
}
