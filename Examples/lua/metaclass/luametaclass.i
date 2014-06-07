/* -----------------------------------------------------------------------------
 * luametaclass.i
 *
 * This file contains metaclass library that allows editing wrappers in runtime.
 * Library is optional and could be enabled/disabled via cmd line argumets.
 * This file is used to generate appropriate luametaclass.swg file.
 * File must follow C89 standard.
 * ----------------------------------------------------------------------------- */

%module luametaclass

%ignore SWIG_Lua_return_hack;

%typemap(out) SWIG_Lua_return_hack %{ SWIG_arg = $1.numargs; %}

%typemap(varin) SWIG_Lua_return_hack %{ WTF(); %}

%header %{
  struct SWIG_Lua_metaclass;
  struct SWIG_Lua_metaclass* SWIG_Lua_metaclass_create_by_metatable(lua_State *L);
  void SWIG_Lua_metaclass_set_member( struct SWIG_Lua_metaclass *, lua_State *);
  static int is_type_callable(int);
%}

%inline %{
  typedef struct SWIG_Lua_metaclass {
    /* Name of the class. Struct DOESN'T own string */
    const char* class_cname;
  } SWIG_Lua_metaclass;

  typedef struct {
    int numargs;
  } SWIG_Lua_return_hack;

  /* Those 2 classes are for demonsration purposes only. They are not part
   * of the metaclass library */
  typedef struct {
  } EmptyClass;

  struct Derived : public EmptyClass {
  };
%}

%ignore SWIG_Lua_metaclass_create_by_metatable;
%ignore SWIG_Lua_metaclass_set_member;
%ignore is_type_callable;

%inline %{
  /* Auxilary function. Input - class metatable on the top of the stack.
   * Output - new SWIG_Lua_metaclass structure
   */
  SWIG_Lua_metaclass* SWIG_Lua_metaclass_create_by_metatable( lua_State *L )
  {
    SWIG_Lua_metaclass *m = 0;
    swig_lua_class *class_obj = 0;

    assert(lua_istable(L,-1));
    lua_pushstring(L,".type_info");
    lua_gettable(L,-2);
    assert(lua_type(L,-1) == LUA_TLIGHTUSERDATA);
    class_obj = (swig_lua_class*) lua_touserdata(L,-1);
    m = (SWIG_Lua_metaclass*) malloc( sizeof(SWIG_Lua_metaclass) );
    m->class_cname = class_obj->fqname;
    return m;
  }

  /* Auxilary function. Checks that given type is potentially callable */
  static int is_type_callable( int type ) {
    return type == LUA_TUSERDATA || type == LUA_TTABLE || type == LUA_TFUNCTION;
  }

  /* Sets getters and setters of class member to specified value
   * Input - in stack
   * (-3) - string, member name
   * (-2) - value, getter
   * (-1) - value, setter
   * Any value (getter or setter) could be nil. That will effectively delete
   * setter and/or getter.
   * Function is not exposed to the user. Getter/setter are not checked for
   * being callable.
   */

  void SWIG_Lua_metaclass_set_member( SWIG_Lua_metaclass* self, lua_State *L )
  {
    int membername_index;
    int getter_index;
    int setter_index;
    /* The callee must ensure correct number of arguments and correct types */
    assert( lua_gettop(L) >= 3);
    assert( lua_type(L,-3) == LUA_TSTRING );
    membername_index = lua_absindex(L,-3);
    getter_index = lua_absindex(L,-2);
    setter_index = lua_absindex(L,-1);

    SWIG_Lua_get_class_metatable(L, self->class_cname );

    lua_pushstring(L,".get");
    lua_rawget(L,-2); /* aquire .get table */
    assert( !lua_isnil(L,-1) );
    lua_pushvalue(L,membername_index);
    lua_pushvalue(L,getter_index);
    lua_rawset(L,-3);
    lua_pop(L,1); /* pop .get table */

    lua_pushstring(L,".set");
    lua_rawget(L,-2); /* aquire .set table */
    assert( !lua_isnil(L,-1) );
    lua_pushvalue(L,membername_index);
    lua_pushvalue(L,setter_index);
    lua_rawset(L,-3);
    lua_pop(L,1); /* pop .set table */

    return;
  }


%}

%feature("unlimited_args") SWIG_Lua_metaclass::SWIG_Lua_metaclass;
%feature("unlimited_args") SWIG_Lua_metaclass::getFunctions;
%feature("unlimited_args") SWIG_Lua_metaclass::setMemberVariable;
%feature("unlimited_args") SWIG_Lua_metaclass::removeMemberVariable;

%extend SWIG_Lua_metaclass {
      SWIG_Lua_metaclass( lua_State *L ) {
        swig_lua_userdata *usr = 0;
        swig_type_info *type = 0;
        swig_lua_class *class_obj = 0;
        const char *class_cname = 0;
        SWIG_Lua_metaclass *m = 0;
        size_t string_len = 0;

        SWIG_check_num_args( "SWIG_Lua_metaclass::SWIG_Lua_metaclass", 1, 1);
        /* 1. SWIG-wrapped object. Currently there is no way to distinguish SWIG-wrapped objects from other userdata,
         * so just assume it is SWIG userdata */
        if (lua_isuserdata(L,-1) ) {
          usr=(swig_lua_userdata*)lua_touserdata(L,-1);  /* get data */
          type = usr->type;
          class_obj = (swig_lua_class*)type->clientdata;
          m = (SWIG_Lua_metaclass*) malloc( sizeof(SWIG_Lua_metaclass) );
          m->class_cname = class_obj->fqname;
          return m;
        }

        /* 2. Class 'registry entry'. Table with static members of the class, also used for class creation.
         * E.g. "OuterNamespace.InnterNamespace.MyClass"
         */
        if (lua_istable(L,-1) ) {
          /* 'Class static' table has special member '.instance' stored in it's metatable. Check for it */
          if (lua_getmetatable(L,-1) != 0 ) {
            lua_pushstring(L, ".instance");
            lua_gettable(L,-2);
            if (!lua_isnil(L,-1) ) {
              /* Bingo. It was class static table. And now we have class instance metatable on the top of the stack */
              m = SWIG_Lua_metaclass_create_by_metatable(L);
              return m;
            } else {
              lua_pop(L,2); /* Cleaning up. Metatable + nil */
            }
          }
        }

        assert(lua_gettop(L) == 1);
        /* 3. Just class name. Name must be fully qualified and mangled.*/
        if (lua_type(L,-1) == LUA_TSTRING ) {
          SWIG_Lua_get_class_registry(L);
          lua_pushvalue(L,1);
          lua_gettable(L,-2);
          if (!lua_isnil(L,-1)) {
            /* Class exists */
            m = SWIG_Lua_metaclass_create_by_metatable(L);
            return m;
          } else {
            lua_pop(L,1);
          }
        }

        SWIG_Lua_pusherrstring(L,"Wrong arguments for overloaded function 'SWIG_Lua_metaclass(constructor)'\n"
          "  Possible C/C++ prototypes are:\n"
          "    SWIG_Lua_metaclass( <object of desired_class> )\n"
          "    SWIG_Lua_metaclass( <class record> )\n"
          "    SWIG_Lua_metaclass( <class fully qualified mangled name> )\n");
        lua_error(L);
        return 0;

fail:
        lua_error(L);
        return 0;
      }

      ~SWIG_Lua_metaclass() {
        free($self);
      }

      /* Returns table with functions */
      SWIG_Lua_return_hack getFunctions( lua_State *L ) {

        SWIG_Lua_get_class_metatable(L, $self->class_cname);
        lua_pushstring(L,".fn");
        lua_gettable(L,-2);

        assert(lua_istable(L,-1));

        SWIG_Lua_return_hack ret;
        ret.numargs = 1;
        return ret;
      }

      /* Sets member variable
       * Input - in stack:
       *      (1) - $self, already extracted by SWIG
       *      (2) - name
       *      (3) - getter
       *      (4) - setter (optional)
       */
      SWIG_Lua_return_hack setMemberVariable( lua_State *L ) {
        int arg1_type;
        int arg2_type;
        SWIG_Lua_return_hack ret;
        /* Arguments to function starts from 2. Position 1 is occupied by
         * $self, that will be extracted by SWIG runtime
         */
        const int begin = 2;

        /* For the same reasons we add +1 to bounding constants */
        SWIG_check_num_args("SWIG_Lua_metaclass::setMemberVariable",2+1,3+1);
        
        if (lua_type(L,begin) != LUA_TSTRING)
          SWIG_fail_arg("setMemberVariable", 1, "string");

        /* Setters/getters must be potentially callable - userdata, table or functions */
        arg1_type = lua_type(L,begin+1);
        if (!is_type_callable(arg1_type) )
          SWIG_fail_arg("setMemberVariable", 2, "<callable>");

        arg2_type = LUA_TNIL;
        if (lua_gettop(L) > begin + 1) {
          arg2_type = lua_type(L,begin + 2);
          if (!is_type_callable(arg2_type)) 
            SWIG_fail_arg("setMemberVariable", 3, "<callable>");
        } else {
          lua_pushnil(L); /* setter is actually 'nil' value. Place it to stack */
        }

        SWIG_Lua_metaclass_set_member( $self, L );

        ret.numargs = 0;
        return ret;

fail:
        lua_error(L);
        /* The code below will never be executed */
        ret.numargs = 0;
        return ret;
      }

      /* Removes given variable
       * Input - in stack:
       * (1) - name
       */
      SWIG_Lua_return_hack removeMemberVariable( lua_State *L ) {
        SWIG_Lua_return_hack ret;
        /* Arguments to function starts from 2. Position 1 is occupied by
         * $self, that will be extracted by SWIG runtime
         */
        const int begin = 2;
        /* For the same reasons we add +1 to bounding constants */
        SWIG_check_num_args("SWIG_Lua_metaclass::removeMemberVariable",1+1,1+1);

        if(lua_type(L,begin) != LUA_TSTRING) {
          SWIG_fail_arg("removeMemberVariable", 1, "string");
        }

        lua_pushnil(L); /* getter */
        lua_pushnil(L); /* setter */

        SWIG_Lua_metaclass_set_member( $self, L );

        ret.numargs = 0;
        return ret;

fail:
        lua_error(L);
        /* The code below will never be executed */
        ret.numargs = 0;
        return ret;
      }
}


