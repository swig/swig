//
// octrunclass.swg - Octave runtime classes
//

////////// Octave class: SwigOctType //////////

const SwigOctMember* SwigOctType::find_member(const swig_type_info* type, const std::string& name)
{
  if (!type->clientdata) {
    return 0;
  }
  SwigOctClass* c = (SwigOctClass*) type->clientdata;
  const SwigOctMember* m;
  for (m = c->members; m->name; ++m)
    if (m->name == name) {
      return m;
    }
  for (int j = 0; c->base_names[j]; ++j) {
    if (!c->base[j]) {
      if (!module) {
        module = SWIG_GetModule(0);
      }
      assert(module);
      c->base[j] = SWIG_MangledTypeQueryModule(module, module, c->base_names[j]);
    }
    if (!c->base[j]) {
      return 0;
    }
    if ((m = find_member(c->base[j], name))) {
      return m;
    }
  }
  return 0;
}

SwigOctType::member_value_pair* SwigOctType::find_member(const std::string& name, bool insert_if_not_found)
{
  member_map::iterator it = members.find(name);
  if (it != members.end()) {
    return &it->second;
  }
  const SwigOctMember* m;
  for (unsigned int j = 0; j < types.size(); ++j)
    if ((m = find_member(types[j].first, name))) {
      return &members.insert(std::make_pair(name, std::make_pair(m, octave_value()))).first->second;
    }
  if (!insert_if_not_found) {
    return 0;
  }
  return &members[name];
}

const swig_type_info* SwigOctType::find_base(const std::string& name, const swig_type_info* base)
{
  if (!base) {
    for (unsigned int j = 0; j < types.size(); ++j) {
      assert(types[j].first->clientdata);
      SwigOctClass* cj = (SwigOctClass*) types[j].first->clientdata;
      if (cj->name == name) {
        return types[j].first;
      }
    }
    return 0;
  }
  assert(base->clientdata);
  SwigOctClass* c = (SwigOctClass*) base->clientdata;
  for (int j = 0; c->base_names[j]; ++j) {
    if (!c->base[j]) {
      if (!module) {
        module = SWIG_GetModule(0);
      }
      assert(module);
      c->base[j] = SWIG_MangledTypeQueryModule(module, module, c->base_names[j]);
    }
    if (!c->base[j]) {
      return 0;
    }
    assert(c->base[j]->clientdata);
    SwigOctClass* cj = (SwigOctClass*) c->base[j]->clientdata;
    if (cj->name == name) {
      return c->base[j];
    }
  }
  return 0;
}

void SwigOctType::load_members(const SwigOctClass* c, member_map& out) const
{
  for (const SwigOctMember* m = c->members; m->name; ++m) {
    if (out.find(m->name) == out.end()) {
      out.insert(std::make_pair(m->name, std::make_pair(m, octave_value())));
    }
  }
  for (int j = 0; c->base_names[j]; ++j) {
    if (!c->base[j]) {
      if (!module) {
        module = SWIG_GetModule(0);
      }
      assert(module);
      c->base[j] = SWIG_MangledTypeQueryModule(module, module, c->base_names[j]);
    }
    if (!c->base[j]) {
      continue;
    }
    assert(c->base[j]->clientdata);
    const SwigOctClass* cj =
      (const SwigOctClass*) c->base[j]->clientdata;
    load_members(cj, out);
  }
}

void SwigOctType::load_members(member_map& out) const
{
  out = members;
  for (unsigned int j = 0; j < types.size(); ++j)
    if (types[j].first->clientdata) {
      load_members((const SwigOctClass*) types[j].first->clientdata, out);
    }
}

octave_value_list SwigOctType::member_invoke(member_value_pair* m, const octave_value_list& args, int nargout)
{
  if (m->second.is_defined()) {
    return m->second.subsref("(", std::list < octave_value_list > (1, args), nargout);
  } else if (m->first && m->first->method) {
    return m->first->method(args, nargout);
  }
  error("member not defined or not invocable");
  return octave_value_list();
}

bool SwigOctType::dispatch_unary_op(const std::string& symbol, octave_value& ret)
{
  member_value_pair* m = find_member(symbol, false);
  if (!m || m->first->is_static() || m->first->is_global()) {
    return false;
  }
  octave_value_list args;
  args.append(as_value());
  octave_value_list argout(member_invoke(m, args, 1));
  if (argout.length() < 1) {
    return false;
  }
  ret = argout(0);
  return true;
}

bool SwigOctType::dispatch_binary_op(const std::string& symbol, const octave_base_value& rhs, octave_value& ret)
{
  member_value_pair* m = find_member(symbol, false);
  if (!m || m->first->is_static() || m->first->is_global()) {
    return false;
  }
  octave_value_list args;
  args.append(as_value());
  args.append(make_value_hack(rhs));
  octave_value_list argout(member_invoke(m, args, 1));
  if (argout.length() < 1) {
    return false;
  }
  ret = argout(0);
  return true;
}

bool SwigOctType::dispatch_index_op(const std::string& symbol, const octave_value_list& rhs, octave_value_list& ret)
{
  member_value_pair* m = find_member(symbol, false);
  if (!m || m->first->is_static() || m->first->is_global()) {
    return false;
  }
  octave_value_list args;
  args.append(as_value());
  args.append(rhs);
  octave_value_list argout(member_invoke(m, args, 1));
  if (argout.length() >= 1) {
    ret = argout(0);
  }
  return true;
}

octave_value_list SwigOctType::member_deref(member_value_pair* m, const octave_value_list& args)
{
  if (m->second.is_defined()) {
    return m->second;
  } else if (m->first) {
    if (m->first->get_method) {
      return m->first->get_method(args, 1);
    } else if (m->first->method) {
      return octave_value(new octave_builtin(m->first->method));
    }
  }
  error("undefined member");
  return octave_value_list();
}

octave_value SwigOctType::make_value_hack(const octave_base_value& x)
{
  ((SwigOctType&) x).count++;
  return octave_value((octave_base_value*) &x);
}

SwigOctType::SwigOctType(void* _ptr, const swig_type_info* _type, int _own, bool _always_static)
  : module(0), construct_type(_ptr ? 0 : _type), own(_own), always_static(_always_static)
{
  if (_type || _ptr) {
    types.push_back(std::make_pair(_type, _ptr));
  }
#ifdef SWIG_DIRECTORS
  if (_ptr) {
    Swig::Director* d = Swig::get_rtdir(_ptr);
    if (d) {
      Swig::swig_director_set_self(d, this);
    }
  }
#endif
}

SwigOctType::~SwigOctType()
{
  if (own) {
    ++count;
    for (unsigned int j = 0; j < types.size(); ++j) {
      if (!types[j].first || !types[j].first->clientdata) {
        continue;
      }
      SwigOctClass* c = (SwigOctClass*) types[j].first->clientdata;
      if (c->destructor && !types[j].second.destroyed && types[j].second.ptr) {
        c->destructor(as_value(), 0);
      }
    }
  }
#ifdef SWIG_DIRECTORS
  for (unsigned int j = 0; j < types.size(); ++j) {
    Swig::erase_rtdir(types[j].second.ptr);
  }
#endif
}

dim_vector SwigOctType::dims(void) const
{
  SwigOctType* nc_this = const_cast < SwigOctType*>(this);

  // Find the __dims__ method of this object
  member_value_pair* m = nc_this->find_member("__dims__", false);

  if (!m) {
    return dim_vector(1, 1);
  }

  // Call the __dims__ method of this object
  octave_value_list inarg;
  inarg.append(nc_this->as_value());
  octave_value_list outarg = nc_this->member_invoke(m, inarg, 1);

  // __dims__ should return (at least) one output argument
  if (outarg.length() < 1) {
    return dim_vector(1, 1);
  }

  octave_value& out = outarg(0);

  // Return value should be cell or matrix of integers
  if (out.is_cell()) {
    const Cell& c = out.cell_value();
    int ndim = c.rows();
    if (ndim == 1 && c.columns() != 1) {
      ndim = c.columns();
    }

    dim_vector d;
    d.resize(ndim < 2 ? 2 : ndim);
    d(0) = d(1) = 1;

    // Fill in dim_vector
    for (int k = 0; k < ndim; k++) {
      const octave_value& obj = c(k);
      d.elem(k) = obj.int_value();

      // __dims__ should return a cell filled with integers
      if (error_state) {
        return dim_vector(1, 1);
      }
    }
    return d;
  } else if (out.is_matrix_type() || out.is_numeric_type()) {
    if (out.rows() == 1 || out.columns() == 1) {
      Array<int> a = out.int_vector_value();
      if (error_state) {
        return dim_vector(1, 1);
      }
      dim_vector d;
      d.resize(a.numel() < 2 ? 2 : a.numel());
      d(0) = d(1) = 1;
      for (int k = 0; k < a.numel(); k++) {
        d.elem(k) = a(k);
      }
      return d;
    } else {
      return dim_vector(1, 1);
    }
  } else {
    return dim_vector(1, 1);
  }
}

octave_value SwigOctType::as_value()
{
  ++count;
  return SWIG_Octave_ValueRef(this);
}

void SwigOctType::incref()
{
  ++count;
}

void SwigOctType::decref()
{
  if (!--count) {
    delete this;
  }
}

long SwigOctType::swig_this() const
{
  if (!types.size()) {
    return (long) this;
  }
  return (long) types[0].second.ptr;
}

std::string SwigOctType::swig_type_name() const
{
  // * need some way to manually name subclasses.
  // * eg optional first arg to subclass(), or named_subclass()
  std::string ret;
  for (unsigned int j = 0; j < types.size(); ++j) {
    if (j) {
      ret += "_";
    }
    if (types[j].first->clientdata) {
      SwigOctClass* c = (SwigOctClass*) types[j].first->clientdata;
      ret += c->name;
    } else {
      ret += types[j].first->name;
    }
  }
  return ret;
}

void SwigOctType::merge(SwigOctType& rhs)
{
  rhs.own = 0;
  for (unsigned int j = 0; j < rhs.types.size(); ++j) {
    assert(!rhs.types[j].second.destroyed);
#ifdef SWIG_DIRECTORS
    Swig::Director* d = Swig::get_rtdir(rhs.types[j].second.ptr);
    if (d) {
      Swig::swig_director_set_self(d, this);
    }
#endif
  }
  types.insert(types.end(), rhs.types.begin(), rhs.types.end());
  members.insert(rhs.members.begin(), rhs.members.end());
  rhs.types.clear();
  rhs.members.clear();
}

SwigOctType::swig_member_const_iterator SwigOctType::swig_members_begin()
{
  return members.begin();
}

SwigOctType::swig_member_const_iterator SwigOctType::swig_members_end()
{
  return members.end();
}

void* SwigOctType::cast(swig_type_info* type, int* _own, int flags)
{
  if (_own) {
    *_own = own;
  }
  if (flags & SWIG_POINTER_DISOWN) {
    own = 0;
  }
  if (!type && types.size()) {
    return types[0].second.ptr;
  }
  for (unsigned int j = 0; j < types.size(); ++j)
    if (type == types[j].first) {
      return types[j].second.ptr;
    }
  for (unsigned int j = 0; j < types.size(); ++j) {
    swig_cast_info* tc = SWIG_TypeCheck(types[j].first->name, type);
    if (!tc) {
      continue;
    }
    int newmemory = 0;
    void* vptr = SWIG_TypeCast(tc, types[j].second.ptr, &newmemory);
    assert(!newmemory);	// newmemory handling not yet implemented
    return vptr;
  }
  return 0;
}

bool SwigOctType::is_owned() const
{
  return own;
}

#ifdef SWIG_DIRECTORS
void SwigOctType::director_destroyed(Swig::Director* d)
{
  bool found = false;
  for (unsigned int j = 0; j < types.size(); ++j) {
    Swig::Director* dj = Swig::get_rtdir(types[j].second.ptr);
    if (dj == d) {
      types[j].second.destroyed = true;
      found = true;
    }
  }
  assert(found);
}
#endif

void SwigOctType::assign(const std::string& name, const octave_value& ov)
{
  members[name] = std::make_pair((const SwigOctMember*) 0, ov);
}

void SwigOctType::assign(const std::string& name, const SwigOctMember* m)
{
  members[name] = std::make_pair(m, octave_value());
}

octave_base_value* SwigOctType::clone() const
{
  // pass-by-value is probably not desired, and is harder;
  // requires calling copy constructors of contained types etc.
  assert(0);
  * (int*) 0 = 0;
  return 0;
}

octave_base_value* SwigOctType::empty_clone() const
{
  return new SwigOctType();
}

bool SwigOctType::is_defined() const
{
  return true;
}

bool SwigOctType::is_map() const
{
  return true;
}

octave_value SwigOctType::subsref(const std::string& ops, const std::list < octave_value_list > &idx)
{
  octave_value_list ovl = subsref(ops, idx, 1);
  return ovl.length() ? ovl(0) : octave_value();
}

octave_value_list SwigOctType::subsref(const std::string& ops, const std::list < octave_value_list > &idx, int nargout)
{
  assert(ops.size() > 0);
  assert(ops.size() == idx.size());

  std::list < octave_value_list >::const_iterator idx_it = idx.begin();
  int skip = 0;
  octave_value_list sub_ovl;

  // constructor invocation
  if (ops[skip] == '(' && construct_type) {
    assert(construct_type->clientdata);
    SwigOctClass* c = (SwigOctClass*) construct_type->clientdata;
    if (!c->constructor) {
      error("cannot create instance");
      return octave_value_list();
    }
    octave_value_list args;
    if (c->director) {
      args.append(SWIG_Octave_ValueRef(new SwigOctType(this, 0, 0)));
    }
    args.append(*idx_it++);
    ++skip;
    sub_ovl = c->constructor(args, nargout);
  }
  // member dereference or invocation
  else if (ops[skip] == '.') {
    std::string subname;
    const swig_type_info* base = 0;	// eg, a.base.base_cpp_mem
    for (;;) {
      octave_value_list subname_ovl(*idx_it++);
      ++skip;
      assert(subname_ovl.length() == 1 && subname_ovl(0).is_string());
      subname = subname_ovl(0).string_value();

      const swig_type_info* next_base = find_base(subname, base);
      if (!next_base || skip >= (int) ops.size() || ops[skip] != '.') {
        break;
      }
      base = next_base;
    }

    member_value_pair tmp, *m = &tmp;
    if (!base || !(m->first = find_member(base, subname))) {
      m = find_member(subname, false);
    }
    if (!m) {
      error("member not found");
      return octave_value_list();
    }

    octave_value_list args;
    if (!always_static &&
        (!m->first || (!m->first->is_static() && !m->first->is_global()))) {
      args.append(as_value());
    }
    if (skip < (int) ops.size() && ops[skip] == '(' &&
        ((m->first && m->first->method) || m->second.is_function() ||
         m->second.is_function_handle())) {
      args.append(*idx_it++);
      ++skip;
      sub_ovl = member_invoke(m, args, nargout);
    } else {
      sub_ovl = member_deref(m, args);
    }
  }
  // index operator
  else {
    if (ops[skip] == '(' || ops[skip] == '{') {
      const char* op_name = ops[skip] == '(' ? "__paren__" : "__brace__";
      octave_value_list args;
      args.append(*idx_it++);
      ++skip;
      if (!dispatch_index_op(op_name, args, sub_ovl)) {
        error("error evaluating index operator");
        return octave_value_list();
      }
    } else {
      error("unsupported subsref");
      return octave_value_list();
    }
  }

  if (skip >= (int) ops.size()) {
    return sub_ovl;
  }
  if (sub_ovl.length() < 1) {
    error("bad subs ref");
    return octave_value_list();
  }
  return sub_ovl(0).next_subsref(nargout, ops, idx, skip);
}

octave_value SwigOctType::subsasgn(const std::string& ops, const std::list < octave_value_list > &idx, const octave_value& rhs)
{
  assert(ops.size() > 0);
  assert(ops.size() == idx.size());

  std::list < octave_value_list >::const_iterator idx_it = idx.begin();
  int skip = 0;

  if (ops.size() > 1) {
    std::list < octave_value_list >::const_iterator last = idx.end();
    --last;
    std::list < octave_value_list > next_idx(idx.begin(), last);
    octave_value next_ov = subsref(ops.substr(0, ops.size() - 1), next_idx);
    next_ov.subsasgn(ops.substr(ops.size() - 1), std::list < octave_value_list > (1, *last), rhs);
  }

  else if (ops[skip] == '(' || ops[skip] == '{') {
    const char* op_name = ops[skip] == '(' ? "__paren_asgn__" : "__brace_asgn__";
    member_value_pair* m = find_member(op_name, false);
    if (m) {
      octave_value_list args;
      args.append(as_value());
      args.append(*idx_it);
      args.append(rhs);
      member_invoke(m, args, 1);
    } else {
      error("%s member not found", op_name);
    }
  }

  else if (ops[skip] == '.') {
    octave_value_list subname_ovl(*idx_it++);
    ++skip;
    assert(subname_ovl.length() == 1 && subname_ovl(0).is_string());
    std::string subname = subname_ovl(0).string_value();

    member_value_pair* m = find_member(subname, true);
    if (!m->first || !m->first->set_method) {
      m->first = 0;
      m->second = rhs;
    } else if (m->first->set_method) {
      octave_value_list args;
      if (!m->first->is_static() && !m->first->is_global()) {
        args.append(as_value());
      }
      args.append(rhs);
      m->first->set_method(args, 1);
    } else {
      error("member not assignable");
    }
  } else {
    error("unsupported subsasgn");
  }

  return as_value();
}

bool SwigOctType::is_object() const
{
  return true;
}

bool SwigOctType::is_string() const
{
  SwigOctType* nc_this = const_cast < SwigOctType*>(this);
  return !!nc_this->find_member("__str__", false);
}

std::string SwigOctType::string_value(bool force) const
{
  SwigOctType* nc_this = const_cast < SwigOctType*>(this);
  member_value_pair* m = nc_this->find_member("__str__", false);
  if (!m) {
    error("__str__ method not defined");
    return std::string();
  }
  octave_value_list outarg = nc_this->member_invoke(m, octave_value_list(nc_this->as_value()), 1);
  if (outarg.length() < 1 || !outarg(0).is_string()) {
    error("__str__ method did not return a string");
    return std::string();
  }
  return outarg(0).string_value();
}

octave_map SwigOctType::map_value() const
{
  return octave_map();
}

string_vector SwigOctType::map_keys() const
{
  member_map tmp;
  load_members(tmp);

  string_vector keys(tmp.size());
  int k = 0;
  for (member_map::iterator it = tmp.begin(); it != tmp.end(); ++it) {
    keys(k++) = it->first;
  }

  return keys;
}

bool SwigOctType::save_ascii(std::ostream& os)
{
  return true;
}

bool SwigOctType::load_ascii(std::istream& is)
{
  return true;
}

bool SwigOctType::save_binary(std::ostream& os, bool& save_as_floats)
{
  return true;
}

bool SwigOctType::load_binary(std::istream& is, bool swap, oct_mach_info::float_format fmt)
{
  return true;
}

#ifdef HAVE_HDF5
bool SwigOctType::save_hdf5(hid_t loc_id, const char* name, bool save_as_floats)
{
  return true;
}

bool SwigOctType::load_hdf5(hid_t loc_id, const char* name, bool have_h5giterate_bug)
{
  return true;
}
#endif

octave_value SwigOctType::convert_to_str(bool pad, bool force, char type) const
{
  return string_value();
}

octave_value SwigOctType::convert_to_str_internal(bool pad, bool force, char type) const
{
  return string_value();
}

bool SwigOctType::dispatch_global_op(const std::string& symbol, const octave_value_list& args, octave_value& ret)
{
  // we assume that SWIG_op_prefix-prefixed functions are installed in global namespace
  // (rather than any module namespace).

  octave_function* fcn = is_valid_function(symbol, std::string(), false);
  if (!fcn) {
    return false;
  }
  ret = fcn->do_multi_index_op(1, args)(0);
  return true;
}

octave_value SwigOctType::dispatch_unary_op(const octave_base_value& x, const char* op_name)
{
  SwigOctType* ost = SWIG_Octave_ValueDeref(x);
  assert(ost);

  octave_value ret;
  if (ost->dispatch_unary_op(std::string("__") + op_name + std::string("__"), ret)) {
    return ret;
  }
  std::string symbol = SWIG_op_prefix + ost->swig_type_name() + "_" + op_name;
  octave_value_list args;
  args.append(make_value_hack(x));
  if (dispatch_global_op(symbol, args, ret)) {
    return ret;
  }

  error("could not dispatch unary operator");
  return octave_value();
}

octave_value SwigOctType::dispatch_binary_op(const octave_base_value& lhs, const octave_base_value& rhs, const char* op_name)
{
  SwigOctType* lhs_ost = SWIG_Octave_ValueDeref(lhs);
  SwigOctType* rhs_ost = SWIG_Octave_ValueDeref(rhs);

  octave_value ret;
  if (lhs_ost && lhs_ost->dispatch_binary_op(std::string("__") + op_name + std::string("__"), rhs, ret)) {
    return ret;
  }
  if (rhs_ost) {
    if (strlen(op_name) == 2  && (op_name[1] == 't' || op_name[1] == 'e')) {
      if (op_name[0] == 'l' && rhs_ost->dispatch_binary_op(std::string("__g") + op_name[1] + std::string("__"), lhs, ret)) {
        return ret;
      }
      if (op_name[0] == 'g' && rhs_ost->dispatch_binary_op(std::string("__l") + op_name[1] + std::string("__"), lhs, ret)) {
        return ret;
      }
    }
    if (rhs_ost->dispatch_binary_op(std::string("__r") + op_name + std::string("__"), lhs, ret)) {
      return ret;
    }
  }

  std::string symbol;
  octave_value_list args;
  args.append(make_value_hack(lhs));
  args.append(make_value_hack(rhs));

  symbol = SWIG_op_prefix;
  symbol += lhs_ost ? lhs_ost->swig_type_name() : lhs.type_name();
  symbol += "_";
  symbol += op_name;
  symbol += "_";
  symbol += rhs_ost ? rhs_ost->swig_type_name() : rhs.type_name();
  if (dispatch_global_op(symbol, args, ret)) {
    return ret;
  }

  symbol = SWIG_op_prefix;
  symbol += lhs_ost ? lhs_ost->swig_type_name() : lhs.type_name();
  symbol += "_";
  symbol += op_name;
  symbol += "_";
  symbol += "any";
  if (dispatch_global_op(symbol, args, ret)) {
    return ret;
  }

  symbol = SWIG_op_prefix;
  symbol += "any";
  symbol += "_";
  symbol += op_name;
  symbol += "_";
  symbol += rhs_ost ? rhs_ost->swig_type_name() : rhs.type_name();
  if (dispatch_global_op(symbol, args, ret)) {
    return ret;
  }

  error("could not dispatch binary operator");
  return octave_value();
}

void SwigOctType::print(std::ostream& os, bool pr_as_read_syntax) const
{
  if (is_string()) {
    os << string_value();
    return;
  }

  member_map tmp;
  load_members(tmp);

  indent(os);
  os << "{";
  newline(os);
  increment_indent_level();
  for (unsigned int j = 0; j < types.size(); ++j) {
    indent(os);
    if (types[j].first->clientdata) {
      const SwigOctClass* c = (const SwigOctClass*) types[j].first->clientdata;
      os << c->name << ", ptr = " << types[j].second.ptr;
      newline(os);
    } else {
      os << types[j].first->name << ", ptr = " << types[j].second.ptr;
      newline(os);
    }
  }
  for (member_map::const_iterator it = tmp.begin(); it != tmp.end(); ++it) {
    indent(os);
    if (it->second.first) {
      const char* objtype = it->second.first->method ? "method" : "variable";
      const char* modifier = (it->second.first->flags & 1) ? "static " : (it->second.first->flags & 2) ? "global " : "";
      os << it->second.first->name << " (" << modifier << objtype << ")";
      newline(os);
      assert(it->second.first->name == it->first);
    } else {
      os << it->first;
      newline(os);
    }
  }
  decrement_indent_level();
  indent(os);
  os << "}";
  newline(os);
}

////////// Octave class: SwigOctRef //////////

DEFINE_OCTAVE_ALLOCATOR(SwigOctRef);
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA(SwigOctRef, "swig_ref", "swig_ref");

SwigOctRef::SwigOctRef(SwigOctType* _ptr)
  : ptr(_ptr)
{ }

SwigOctRef::~SwigOctRef()
{
  if (ptr) {
    ptr->decref();
  }
}

SwigOctType* SwigOctRef::get_ptr() const
{
  return ptr;
}

octave_base_value* SwigOctRef::clone() const
{
  if (ptr) {
    ptr->incref();
  }
  return new SwigOctRef(ptr);
}

octave_base_value* SwigOctRef::empty_clone() const
{
  return new SwigOctRef(0);
}

dim_vector SwigOctRef::dims(void) const
{
  return ptr->dims();
}

bool SwigOctRef::is_defined() const
{
  return ptr->is_defined();
}

bool SwigOctRef::is_map() const
{
  return ptr->is_map();
}

octave_value SwigOctRef::subsref(const std::string& ops, const std::list < octave_value_list > &idx)
{
  return ptr->subsref(ops, idx);
}

octave_value_list SwigOctRef::subsref(const std::string& ops, const std::list < octave_value_list > &idx, int nargout)
{
  return ptr->subsref(ops, idx, nargout);
}

octave_value SwigOctRef::subsasgn(const std::string& ops, const std::list < octave_value_list > &idx, const octave_value& rhs)
{
  return ptr->subsasgn(ops, idx, rhs);
}

bool SwigOctRef::is_object() const
{
  return ptr->is_object();
}

bool SwigOctRef::is_string() const
{
  return ptr->is_string();
}

std::string SwigOctRef::string_value(bool force) const
{
  return ptr->string_value(force);
}

octave_map SwigOctRef::map_value() const
{
  return ptr->map_value();
}

string_vector SwigOctRef::map_keys() const
{
  return ptr->map_keys();
}

bool SwigOctRef::save_ascii(std::ostream& os)
{
  return ptr->save_ascii(os);
}

bool SwigOctRef::load_ascii(std::istream& is)
{
  return ptr->load_ascii(is);
}

bool SwigOctRef::save_binary(std::ostream& os, bool& save_as_floats)
{
  return ptr->save_binary(os, save_as_floats);
}

bool SwigOctRef::load_binary(std::istream& is, bool swap, oct_mach_info::float_format fmt)
{
  return ptr->load_binary(is, swap, fmt);
}

#ifdef HAVE_HDF5
bool SwigOctRef::save_hdf5(hid_t loc_id, const char* name, bool save_as_floats)
{
  return ptr->save_hdf5(loc_id, name, save_as_floats);
}

bool SwigOctRef::load_hdf5(hid_t loc_id, const char* name, bool have_h5giterate_bug)
{
  return ptr->load_hdf5(loc_id, name, have_h5giterate_bug);
}
#endif

octave_value SwigOctRef::convert_to_str(bool pad, bool force, char type) const
{
  return ptr->convert_to_str(pad, force, type);
}

octave_value SwigOctRef::convert_to_str_internal(bool pad, bool force, char type) const
{
  return ptr->convert_to_str_internal(pad, force, type);
}

void SwigOctRef::print(std::ostream& os, bool pr_as_read_syntax) const
{
  return ptr->print(os, pr_as_read_syntax);
}

////////// Octave class: SwigOctPacked //////////

DEFINE_OCTAVE_ALLOCATOR(SwigOctPacked);
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA(SwigOctPacked, "swig_packed", "swig_packed");

SwigOctPacked::SwigOctPacked(swig_type_info* _type, const void* _buf, size_t _buf_len)
  :	type(_type), buf((const char*) _buf, (const char*) _buf + _buf_len)
{ }

bool SwigOctPacked::copy(swig_type_info* outtype, void* ptr, size_t sz) const
{
  if (outtype && outtype != type) {
    return false;
  }
  assert(sz <= buf.size());
  std::copy(buf.begin(), buf.begin() + sz, (char*) ptr);
  return true;
}

octave_base_value* SwigOctPacked::clone() const
{
  return new SwigOctPacked(*this);
}

octave_base_value* SwigOctPacked::empty_clone() const
{
  return new SwigOctPacked();
}

bool SwigOctPacked::is_defined() const
{
  return true;
}

void SwigOctPacked::print(std::ostream& os, bool pr_as_read_syntax) const
{
  indent(os);
  os << "swig packed type: name = " << (type ? type->name : std::string()) << ", len = " << buf.size();
  newline(os);
}

bool SwigOctPacked::save_ascii(std::ostream& os)
{
  return true;
}

bool SwigOctPacked::load_ascii(std::istream& is)
{
  return true;
}

bool SwigOctPacked::save_binary(std::ostream& os, bool& save_as_floats)
{
  return true;
}

bool SwigOctPacked::load_binary(std::istream& is, bool swap, oct_mach_info::float_format fmt)
{
  return true;
}

#ifdef HAVE_HDF5
bool SwigOctPacked::save_hdf5(hid_t loc_id, const char* name, bool save_as_floats)
{
  return true;
}

bool SwigOctPacked::load_hdf5(hid_t loc_id, const char* name, bool have_h5giterate_bug)
{
  return true;
}
#endif

////////// Octave class: Swig::Director and related classes //////////

#ifdef SWIG_DIRECTORS

#include <exception>

Swig::Director::Director(void* vptr) : self(0), swig_disowned(false)
{
  set_rtdir(vptr, this);
}

Swig::Director::~Director()
{
  swig_director_destroyed(self, this);
  if (swig_disowned) {
    self->decref();
  }
}

void Swig::Director::swig_set_self(SwigOctType* new_self)
{
  assert(!swig_disowned);
  self = new_self;
}

SwigOctType* Swig::Director::swig_get_self() const
{
  return self;
}

void Swig::Director::swig_disown()
{
  if (swig_disowned) {
    return;
  }
  swig_disowned = true;
  self->incref();
}

void Swig::DirectorTypeMismatchException::raise(const char* msg)
{
  // ... todo
  throw(DirectorTypeMismatchException());
}

void Swig::DirectorTypeMismatchException::raise(const octave_value& ov, const char* msg)
{
  // ... todo
  raise(msg);
}

void Swig::DirectorPureVirtualException::raise(const char* msg)
{
  // ... todo
  throw(DirectorPureVirtualException());
}

void Swig::DirectorPureVirtualException::raise(const octave_value& ov, const char* msg)
{
  // ... todo
  raise(msg);
}

SWIGOCTRT Swig::rtdir_map* Swig::get_rtdir_map()
{
  static swig_module_info* module = 0;
  if (!module) {
    module = SWIG_GetModule(0);
  }
  if (!module) {
    return 0;
  }
  if (!module->clientdata) {
    module->clientdata = new rtdir_map;
  }
  return (rtdir_map*) module->clientdata;
}

SWIGOCTRTINLINE void Swig::set_rtdir(void* vptr, Director* d)
{
  rtdir_map* rm = get_rtdir_map();
  if (rm) {
    (*rm) [vptr] = d;
  }
}

SWIGOCTRTINLINE void Swig::erase_rtdir(void* vptr)
{
  rtdir_map* rm = get_rtdir_map();
  if (rm) {
    (*rm).erase(vptr);
  }
}

SWIGOCTRTINLINE Swig::Director* Swig::get_rtdir(void* vptr)
{
  rtdir_map* rm = get_rtdir_map();
  if (!rm) {
    return 0;
  }
  rtdir_map::const_iterator pos = rm->find(vptr);
  Director* rtdir = (pos != rm->end()) ? pos->second : 0;
  return rtdir;
}

SWIGOCTRT void Swig::swig_director_destroyed(SwigOctType* self, Director* d)
{
  self->director_destroyed(d);
}

SWIGOCTRT SwigOctType* Swig::swig_director_get_self(Director* d)
{
  return d->swig_get_self();
}

SWIGOCTRT void Swig::swig_director_set_self(Director* d, SwigOctType* self)
{
  d->swig_set_self(self);
}

SWIGOCTRT void swig_acquire_ownership(void* vptr)
{
  //  assert(0);
  // ... todo
}

SWIGOCTRT void swig_acquire_ownership_array(void* vptr)
{
  //  assert(0);
  // ... todo
}

SWIGOCTRT void swig_acquire_ownership_obj(void* vptr, int own)
{
  //  assert(0);
  // ... todo
}

#endif // SWIG_DIRECTORS
