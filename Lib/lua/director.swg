/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that Lua proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

#ifndef SWIG_DIRECTOR_LUA_HEADER_
#define SWIG_DIRECTOR_LUA_HEADER_

#include <string>
#include <exception>
#include <map>

/* Macro to cast a pointer to a director class */
#define SWIG_DIRECTOR_CAST(PTR) (dynamic_cast<Swig::Director*>(PTR))

namespace Swig {

  /* memory handler */
  struct GCItem {
    virtual ~GCItem() {}

    virtual int get_own() const {
      return 0;
    }
  };

  struct GCItem_var {
    GCItem_var(GCItem *item = 0) : _item(item) {
    }

    GCItem_var& operator=(GCItem *item) {
      GCItem *tmp = _item;
      _item = item;
      delete tmp;
      return *this;
    }

    ~GCItem_var() {
      delete _item;
    }

    GCItem * operator->() const {
      return _item;
    }

  private:
    GCItem *_item;
  };

  struct GCItem_Object : GCItem {
    GCItem_Object(int own) : _own(own) {
    }

    virtual ~GCItem_Object() {
    }

    int get_own() const {
      return _own;
    }

  private:
    int _own;
  };

  template <typename Type>
  struct GCItem_T : GCItem {
    GCItem_T(Type *ptr) : _ptr(ptr) {
    }

    virtual ~GCItem_T() {
      delete _ptr;
    }

  private:
    Type *_ptr;
  };

  template <typename Type>
  struct GCArray_T : GCItem {
    GCArray_T(Type *ptr) : _ptr(ptr) {
    }

    virtual ~GCArray_T() {
      delete[] _ptr;
    }

  private:
    Type *_ptr;
  };

  /* base class for director exceptions */
  class DirectorException : public std::exception {
  protected:
    std::string swig_msg;
  public:
    DirectorException(const char *msg = "") : swig_msg(msg) {
    }

    virtual ~DirectorException() SWIG_NOEXCEPT {
    }

    const char *what() const SWIG_NOEXCEPT {
      return swig_msg.c_str();
    }

    static void raise(lua_State *L, const char *msg) {
      luaL_error(L, "SWIG director error: %s", msg);
    }

    static void raise(const char *msg) {
      throw DirectorException(msg);
    }
  };

  /* type mismatch in the return value from a Lua method call */
  class DirectorTypeMismatchException : public DirectorException {
  public:
    DirectorTypeMismatchException(const char *msg = "")
      : DirectorException(msg) {
    }

    static void raise(lua_State *L, const char *msg) {
      luaL_error(L, "SWIG director type mismatch: %s", msg);
    }

    static void raise(const char *msg) {
      throw DirectorTypeMismatchException(msg);
    }
  };

  /* any Lua exception that occurs during a director method call */
  class DirectorMethodException : public DirectorException {
  public:
    DirectorMethodException(const char *msg = "")
      : DirectorException(msg) {
    }

    static void raise(const char *msg) {
      throw DirectorMethodException(msg);
    }
  };

  /* attempt to call a pure virtual method via a director method */
  class DirectorPureVirtualException : public DirectorException {
  public:
    DirectorPureVirtualException(const char *msg = "")
      : DirectorException(msg) {
    }

    static void raise(const char *msg) {
      throw DirectorPureVirtualException(msg);
    }
  };

  /* director base class */
  class Director {
  private:
    /* weak reference to the Lua object - stored as a reference in the registry */
    lua_State *swig_L;
    int swig_ref;
    /* flag indicating whether the object is owned by Lua or C++ */
    mutable bool swig_disown_flag;
    /* counter to track nested director upcalls (to prevent infinite recursion) */
    mutable int swig_upcall_depth;

  public:
    /* wrap a Lua object. */
    Director(lua_State *L) : swig_L(L), swig_ref(LUA_NOREF), swig_disown_flag(false), swig_upcall_depth(0) {
    }

    /* release our weak ref at destruction */
    virtual ~Director() {
      if (swig_ref != LUA_NOREF && swig_L) {
        luaL_unref(swig_L, LUA_REGISTRYINDEX, swig_ref);
        swig_ref = LUA_NOREF;
      }
    }

    /* connect the C++ director to the Lua object */
    void swig_connect_director(lua_State *L, int index) {
      swig_L = L;
      /* Store a reference to the Lua object in the registry */
      lua_pushvalue(L, index);
      swig_ref = luaL_ref(L, LUA_REGISTRYINDEX);
    }

    /* return a pointer to the Lua state */
    lua_State *swig_get_lua_state() const {
      return swig_L;
    }

    /* push the Lua object onto the stack */
    bool swig_get_self(lua_State *L) const {
      if (swig_ref != LUA_NOREF) {
        lua_rawgeti(L, LUA_REGISTRYINDEX, swig_ref);
        return true;
      }
      return false;
    }

    /* check if director is connected to a Lua object */
    bool swig_is_connected() const {
      return swig_ref != LUA_NOREF;
    }

    /* check if we're currently in a director upcall (to prevent infinite recursion) */
    bool swig_is_upcall_active() const {
      return swig_upcall_depth > 0;
    }

    /* increment upcall depth (called when entering a director method) */
    void swig_begin_upcall() const {
      ++swig_upcall_depth;
    }

    /* decrement upcall depth (called when leaving a director method) */
    void swig_end_upcall() const {
      --swig_upcall_depth;
    }

    /* acquire ownership of the wrapped Lua object (the sense of "disown" is from Lua) */
    void swig_disown() const {
      if (!swig_disown_flag) {
        swig_disown_flag = true;
      }
    }

    /* is the object owned by Lua? */
    bool swig_is_disowned() const {
      return swig_disown_flag;
    }

    /* methods to implement pseudo protected director members */
    virtual bool swig_get_inner(const char * /* swig_protected_method_name */) const {
      return true;
    }

    virtual void swig_set_inner(const char * /* swig_protected_method_name */, bool /* swig_val */) const {
    }

  /* ownership management */
  private:
    typedef std::map<void *, GCItem_var> swig_ownership_map;
    mutable swig_ownership_map swig_owner;

  public:
    template <typename Type>
    void swig_acquire_ownership_array(Type *vptr) const {
      if (vptr) {
        swig_owner[vptr] = new GCArray_T<Type>(vptr);
      }
    }

    template <typename Type>
    void swig_acquire_ownership(Type *vptr) const {
      if (vptr) {
        swig_owner[vptr] = new GCItem_T<Type>(vptr);
      }
    }

    void swig_acquire_ownership_obj(void *vptr, int own) const {
      if (vptr && own) {
        swig_owner[vptr] = new GCItem_Object(own);
      }
    }

    int swig_release_ownership(void *vptr) const {
      int own = 0;
      if (vptr) {
        swig_ownership_map::iterator iter = swig_owner.find(vptr);
        if (iter != swig_owner.end()) {
          own = iter->second->get_own();
          swig_owner.erase(iter);
        }
      }
      return own;
    }
  };

  /* helper function to check if a method exists in a Lua table/userdata */
  inline bool SWIG_Lua_director_has_method(lua_State *L, int idx, const char *method_name) {
    bool has_method = false;
    int top = lua_gettop(L);
    
    lua_pushvalue(L, idx);
    lua_pushstring(L, method_name);
    lua_gettable(L, -2);
    
    if (lua_isfunction(L, -1)) {
      has_method = true;
    }
    
    lua_settop(L, top);
    return has_method;
  }

  /* helper function to call a Lua method on an object */
  inline int SWIG_Lua_director_call_method(lua_State *L, int obj_idx, const char *method_name, int nargs, int nresults) {
    /* Get the method from the object */
    lua_pushvalue(L, obj_idx);
    lua_pushstring(L, method_name);
    lua_gettable(L, -2);
    
    if (!lua_isfunction(L, -1)) {
      lua_pop(L, 2); /* pop nil/non-function and object copy */
      std::string msg = "Method '";
      msg += method_name;
      msg += "' not found in Lua object";
      DirectorMethodException::raise(msg.c_str());
      return 0;
    }
    
    /* Remove the extra object copy, keep the function */
    lua_remove(L, -2);
    
    /* Push self (the object) as first argument */
    lua_pushvalue(L, obj_idx);
    
    /* Move the additional arguments below self */
    if (nargs > 0) {
      /* Move self after the arguments */
      lua_insert(L, -(nargs + 1));
      /* Move function before self and arguments */
      lua_insert(L, -(nargs + 2));
    }
    
    /* Call the method with nargs + 1 (including self) */
    if (lua_pcall(L, nargs + 1, nresults, 0) != 0) {
      std::string error = "Error calling director method '";
      error += method_name;
      error += "': ";
      error += lua_tostring(L, -1);
      lua_pop(L, 1);
      DirectorMethodException::raise(error.c_str());
      return 0;
    }
    
    return 1;
  }
}

/* director disown support for classes */
SWIGINTERN int SWIG_Lua_director_class_disown(lua_State *L) {
  /* Get userdata from first argument */
  if (!lua_isuserdata(L, 1)) {
    lua_pushnil(L);
    return 1;
  }
  
  swig_lua_userdata *usr = (swig_lua_userdata *)lua_touserdata(L, 1);
  if (usr) {
    usr->own = 0;
  }
  
  lua_pushvalue(L, 1);
  return 1;
}

/* Helper function to set a method override on a director object.
 * This allows Lua code to override C++ virtual methods without using
 * the debug library directly.
 * Usage: module.swig_director_override(obj, "methodName", function)
 */
SWIGINTERN int SWIG_Lua_director_override(lua_State *L) {
  /* Arguments: obj (userdata), methodName (string), func (function) */
  if (!lua_isuserdata(L, 1)) {
    return luaL_error(L, "First argument must be a SWIG object");
  }
  if (!lua_isstring(L, 2)) {
    return luaL_error(L, "Second argument must be a method name (string)");
  }
  if (!lua_isfunction(L, 3) && !lua_isnil(L, 3)) {
    return luaL_error(L, "Third argument must be a function or nil");
  }
  
  /* Get or create the uservalue table */
  lua_getuservalue(L, 1);
  if (lua_isnil(L, -1)) {
    lua_pop(L, 1);
    lua_newtable(L);
    lua_pushvalue(L, -1); /* duplicate for setuservalue */
    lua_setuservalue(L, 1);
  }
  
  /* Set the method override in the uservalue table */
  lua_pushvalue(L, 2); /* method name */
  lua_pushvalue(L, 3); /* function or nil */
  lua_rawset(L, -3);
  
  lua_pop(L, 1); /* pop uservalue table */
  lua_pushvalue(L, 1); /* return the object for chaining */
  return 1;
}

/* Helper function to get a method override from a director object.
 * Usage: local func = module.swig_director_get_override(obj, "methodName")
 */
SWIGINTERN int SWIG_Lua_director_get_override(lua_State *L) {
  /* Arguments: obj (userdata), methodName (string) */
  if (!lua_isuserdata(L, 1)) {
    return luaL_error(L, "First argument must be a SWIG object");
  }
  if (!lua_isstring(L, 2)) {
    return luaL_error(L, "Second argument must be a method name (string)");
  }
  
  /* Get the uservalue table */
  lua_getuservalue(L, 1);
  if (lua_isnil(L, -1)) {
    /* No uservalue, return nil */
    return 1;
  }
  
  /* Get the method override from the uservalue table */
  lua_pushvalue(L, 2); /* method name */
  lua_rawget(L, -2);
  
  return 1;
}

/* Helper function to create a derived object with multiple overrides.
 * Usage: local obj = module.swig_director_derive(BaseClass(), { method1 = func1, method2 = func2 })
 */
SWIGINTERN int SWIG_Lua_director_derive(lua_State *L) {
  /* Arguments: obj (userdata), overrides (table) */
  if (!lua_isuserdata(L, 1)) {
    return luaL_error(L, "First argument must be a SWIG object");
  }
  if (!lua_istable(L, 2)) {
    return luaL_error(L, "Second argument must be a table of overrides");
  }
  
  /* Get or create the uservalue table */
  lua_getuservalue(L, 1);
  if (lua_isnil(L, -1)) {
    lua_pop(L, 1);
    lua_newtable(L);
    lua_pushvalue(L, -1); /* duplicate for setuservalue */
    lua_setuservalue(L, 1);
  }
  
  /* Iterate over the overrides table and copy to uservalue */
  lua_pushnil(L); /* first key */
  while (lua_next(L, 2) != 0) {
    /* key at -2, value at -1 */
    if (lua_isstring(L, -2) && (lua_isfunction(L, -1) || lua_isnil(L, -1))) {
      lua_pushvalue(L, -2); /* key */
      lua_pushvalue(L, -2); /* value */
      lua_rawset(L, -5); /* set in uservalue table (at -5 after pushing key and value) */
    }
    lua_pop(L, 1); /* pop value, keep key for next iteration */
  }
  
  lua_pop(L, 1); /* pop uservalue table */
  lua_pushvalue(L, 1); /* return the object */
  return 1;
}

#endif

