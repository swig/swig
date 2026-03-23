/* -----------------------------------------------------------------------------
 * std_function.i
 *
 * SWIG typemaps for std::function in Lua.
 *
 * Provides the %std_function(Name, Ret, ...) macro to wrap
 * std::function<Ret(Args...)> so that plain Lua functions can be passed
 * directly where C++ expects a std::function parameter.
 *
 * Usage example:
 *   %std_function(IntCallback, int, int)
 *   // This wraps std::function<int(int)>
 *   // C++ side: int callMe(std::function<int(int)> cb) { return cb(42); }
 *   // Lua side: result = module.callMe(function(x) return x * 2 end)
 *
 * Requirements:
 *   - Directors must be enabled: %module(directors="1")
 *   - C++14 or later (uses generic lambdas with parameter packs)
 * ----------------------------------------------------------------------------- */

%{
#include <functional>
#include <memory>

#ifndef SWIG_DIRECTORS
#error "Directors must be enabled in your SWIG module for std_function.i to work correctly"
#endif
%}

/* Fragment containing all helper functions for std_function support. */
%fragment("SWIG_Lua_std_function_support", "header") {

SWIGINTERN int SWIG_lua_std_function_check(lua_State *L, int idx) {
    return lua_isfunction(L, idx) || lua_isuserdata(L, idx);
}

SWIGINTERN int SWIG_lua_std_function_check_or_nil(lua_State *L, int idx) {
    return lua_isnil(L, idx) || lua_isfunction(L, idx) || lua_isuserdata(L, idx);
}

/* Closure that strips the director 'self' argument and forwards to the user
 * Lua function stored as upvalue 1.
 * When the director calls Invoke, it passes (self, arg1, arg2, ...).
 * This closure removes 'self' and calls user_func(arg1, arg2, ...). */
SWIGINTERN int SWIG_Lua_std_function_closure(lua_State *L) {
    int nargs = lua_gettop(L); /* total args including self */
    lua_pushvalue(L, lua_upvalueindex(1)); /* push the user function */
    /* Push all arguments except self (starting from index 2) */
    for (int i = 2; i <= nargs; i++) {
        lua_pushvalue(L, i);
    }
    lua_call(L, nargs - 1, LUA_MULTRET);
    return lua_gettop(L) - nargs;
}

} /* end fragment */


/* --------------------------------------------------------------------------
 * %std_function(Name, Ret, ...) macro
 * -------------------------------------------------------------------------- */
%define %std_function(Name, Ret, ...)

/* Enable director for the handler class */
%feature("director") Name;

/* Define the handler class in C++ */
%{
struct Name {
    virtual ~Name() {}
    virtual Ret Invoke(##__VA_ARGS__) = 0;
};
%}

/* Define the handler class for SWIG wrapping */
struct Name {
    virtual ~Name();
    virtual Ret Invoke(##__VA_ARGS__) = 0;
};

/* ---- Native std::function wrapper via typedef ----
 * We use a typedef to avoid the 'function' Lua keyword issue.
 * SWIG sees a class named Name_native_type (not a keyword),
 * and the typedef makes it equivalent to std::function<...> in C++. */

%{
typedef std::function<Ret(##__VA_ARGS__)> Name##_native_type;
%}

/* Make SWIG aware of the typedef so type descriptors resolve correctly */
typedef std::function<Ret(##__VA_ARGS__)> Name##_native_type;

/* Rename to NameNative in Lua */
%rename(Name##Native) Name##_native_type;

/* Map operator() to __call metamethod for direct f(args) syntax */
%rename(__call) Name##_native_type::operator();

/* The native std::function wrapper class */
class Name##_native_type {
public:
    /* Copy constructor */
    Name##_native_type(const Name##_native_type &);

    /* Call operator — __call metamethod allows f(args) syntax in Lua */
    Ret operator()(##__VA_ARGS__) const;

    /* Extension: construct from a director-enabled handler */
    %extend {
        Name##_native_type(lua_State *L, Name *in) {
            Swig::Director *director = dynamic_cast<Swig::Director *>(in);
            int ref = LUA_NOREF;
            if (director && L) {
                director->swig_get_self(L);
                swig_lua_userdata *usr = (swig_lua_userdata *)lua_touserdata(L, -1);
                if (usr) usr->own = 0;
                ref = luaL_ref(L, LUA_REGISTRYINDEX);
            }
            return new Name##_native_type(
                [in = std::shared_ptr<Name>(in, [L, ref](Name *p) {
                    if (ref != LUA_NOREF && L) {
                        luaL_unref(L, LUA_REGISTRYINDEX, ref);
                    }
                    delete p;
                })](auto &&...param) -> Ret {
                    return in->Invoke(std::forward<decltype(param)>(param)...);
                }
            );
        }
    }
};

/* ---- Typemap: by-value std::function ---- */
%typemap(in, checkfn="SWIG_lua_std_function_check",
         fragment="SWIG_Lua_std_function_support")
    std::function<Ret(##__VA_ARGS__)>
%{
    if (lua_isfunction(L, $input)) {
        /* Create a director-enabled handler from the Lua function */
        SwigDirector_##Name *swig_handler = new SwigDirector_##Name(L);

        /* Wrap as userdata and connect the director */
        SWIG_NewPointerObj(L, (void *)swig_handler, $descriptor(Name *), 1);
        int swig_handler_idx = lua_gettop(L);
        {
            Swig::Director *d = SWIG_DIRECTOR_CAST(swig_handler);
            if (d) d->swig_connect_director(L, swig_handler_idx);
        }

        /* Set the Lua function (wrapped in a self-stripping closure)
         * as the "Invoke" override in the uservalue table */
        lua_newtable(L);
        lua_pushstring(L, "Invoke");
        lua_pushvalue(L, $input);
        lua_pushcclosure(L, SWIG_Lua_std_function_closure, 1);
        lua_rawset(L, -3);
        lua_setuservalue(L, swig_handler_idx);

        /* Disown: C++ will manage lifetime via shared_ptr */
        {
            swig_lua_userdata *usr = (swig_lua_userdata *)lua_touserdata(L, swig_handler_idx);
            if (usr) usr->own = 0;
        }

        /* Store strong reference in registry to prevent GC */
        lua_pushvalue(L, swig_handler_idx);
        int swig_ref = luaL_ref(L, LUA_REGISTRYINDEX);
        lua_pop(L, 1); /* pop handler userdata */

        /* Create std::function with shared_ptr-based ownership */
        lua_State *swig_captured_L = L;
        Name *swig_captured_ptr = static_cast<Name *>(swig_handler);
        $1 = [captured = std::shared_ptr<Name>(swig_captured_ptr,
                [swig_captured_L, swig_ref](Name *p) {
                    luaL_unref(swig_captured_L, LUA_REGISTRYINDEX, swig_ref);
                    delete p;
                })](auto &&...param) -> Ret {
            return captured->Invoke(std::forward<decltype(param)>(param)...);
        };
    } else {
        /* Standard conversion from existing std::function userdata */
        $&ltype argp;
        if (!SWIG_IsOK(SWIG_ConvertPtr(L, $input, (void **)&argp, $&descriptor, 0))) {
            SWIG_fail_ptr("$symname", $argnum, $&descriptor);
        }
        $1 = *argp;
    }
%}

/* ---- Typemap: const std::function& ---- */
%typemap(in, checkfn="SWIG_lua_std_function_check",
         fragment="SWIG_Lua_std_function_support")
    const std::function<Ret(##__VA_ARGS__)> &
    (std::function<Ret(##__VA_ARGS__)> temp)
%{
    if (lua_isfunction(L, $input)) {
        SwigDirector_##Name *swig_handler = new SwigDirector_##Name(L);
        SWIG_NewPointerObj(L, (void *)swig_handler, $descriptor(Name *), 1);
        int swig_handler_idx = lua_gettop(L);
        {
            Swig::Director *d = SWIG_DIRECTOR_CAST(swig_handler);
            if (d) d->swig_connect_director(L, swig_handler_idx);
        }
        lua_newtable(L);
        lua_pushstring(L, "Invoke");
        lua_pushvalue(L, $input);
        lua_pushcclosure(L, SWIG_Lua_std_function_closure, 1);
        lua_rawset(L, -3);
        lua_setuservalue(L, swig_handler_idx);
        {
            swig_lua_userdata *usr = (swig_lua_userdata *)lua_touserdata(L, swig_handler_idx);
            if (usr) usr->own = 0;
        }
        lua_pushvalue(L, swig_handler_idx);
        int swig_ref = luaL_ref(L, LUA_REGISTRYINDEX);
        lua_pop(L, 1);
        lua_State *swig_captured_L = L;
        Name *swig_captured_ptr = static_cast<Name *>(swig_handler);
        temp = [captured = std::shared_ptr<Name>(swig_captured_ptr,
                [swig_captured_L, swig_ref](Name *p) {
                    luaL_unref(swig_captured_L, LUA_REGISTRYINDEX, swig_ref);
                    delete p;
                })](auto &&...param) -> Ret {
            return captured->Invoke(std::forward<decltype(param)>(param)...);
        };
        $1 = &temp;
    } else {
        if (!SWIG_IsOK(SWIG_ConvertPtr(L, $input, (void **)&$1, $descriptor, 0))) {
            SWIG_fail_ptr("$symname", $argnum, $descriptor);
        }
    }
%}

/* ---- Typemap: std::function* (pointer, accepts nil) ---- */
%typemap(in, checkfn="SWIG_lua_std_function_check_or_nil",
         fragment="SWIG_Lua_std_function_support")
    std::function<Ret(##__VA_ARGS__)> *
    (std::function<Ret(##__VA_ARGS__)> temp)
%{
    if (lua_isnil(L, $input)) {
        $1 = nullptr;
    } else if (lua_isfunction(L, $input)) {
        SwigDirector_##Name *swig_handler = new SwigDirector_##Name(L);
        SWIG_NewPointerObj(L, (void *)swig_handler, $descriptor(Name *), 1);
        int swig_handler_idx = lua_gettop(L);
        {
            Swig::Director *d = SWIG_DIRECTOR_CAST(swig_handler);
            if (d) d->swig_connect_director(L, swig_handler_idx);
        }
        lua_newtable(L);
        lua_pushstring(L, "Invoke");
        lua_pushvalue(L, $input);
        lua_pushcclosure(L, SWIG_Lua_std_function_closure, 1);
        lua_rawset(L, -3);
        lua_setuservalue(L, swig_handler_idx);
        {
            swig_lua_userdata *usr = (swig_lua_userdata *)lua_touserdata(L, swig_handler_idx);
            if (usr) usr->own = 0;
        }
        lua_pushvalue(L, swig_handler_idx);
        int swig_ref = luaL_ref(L, LUA_REGISTRYINDEX);
        lua_pop(L, 1);
        lua_State *swig_captured_L = L;
        Name *swig_captured_ptr = static_cast<Name *>(swig_handler);
        temp = [captured = std::shared_ptr<Name>(swig_captured_ptr,
                [swig_captured_L, swig_ref](Name *p) {
                    luaL_unref(swig_captured_L, LUA_REGISTRYINDEX, swig_ref);
                    delete p;
                })](auto &&...param) -> Ret {
            return captured->Invoke(std::forward<decltype(param)>(param)...);
        };
        $1 = &temp;
    } else {
        if (!SWIG_IsOK(SWIG_ConvertPtr(L, $input, (void **)&$1, $descriptor, 0))) {
            SWIG_fail_ptr("$symname", $argnum, $descriptor);
        }
    }
%}

/* ---- Typemap: std::function&& (rvalue reference) ---- */
%typemap(in, checkfn="SWIG_lua_std_function_check",
         fragment="SWIG_Lua_std_function_support")
    std::function<Ret(##__VA_ARGS__)> &&
    (std::function<Ret(##__VA_ARGS__)> temp)
%{
    if (lua_isfunction(L, $input)) {
        SwigDirector_##Name *swig_handler = new SwigDirector_##Name(L);
        SWIG_NewPointerObj(L, (void *)swig_handler, $descriptor(Name *), 1);
        int swig_handler_idx = lua_gettop(L);
        {
            Swig::Director *d = SWIG_DIRECTOR_CAST(swig_handler);
            if (d) d->swig_connect_director(L, swig_handler_idx);
        }
        lua_newtable(L);
        lua_pushstring(L, "Invoke");
        lua_pushvalue(L, $input);
        lua_pushcclosure(L, SWIG_Lua_std_function_closure, 1);
        lua_rawset(L, -3);
        lua_setuservalue(L, swig_handler_idx);
        {
            swig_lua_userdata *usr = (swig_lua_userdata *)lua_touserdata(L, swig_handler_idx);
            if (usr) usr->own = 0;
        }
        lua_pushvalue(L, swig_handler_idx);
        int swig_ref = luaL_ref(L, LUA_REGISTRYINDEX);
        lua_pop(L, 1);
        lua_State *swig_captured_L = L;
        Name *swig_captured_ptr = static_cast<Name *>(swig_handler);
        temp = [captured = std::shared_ptr<Name>(swig_captured_ptr,
                [swig_captured_L, swig_ref](Name *p) {
                    luaL_unref(swig_captured_L, LUA_REGISTRYINDEX, swig_ref);
                    delete p;
                })](auto &&...param) -> Ret {
            return captured->Invoke(std::forward<decltype(param)>(param)...);
        };
        $1 = &temp;
    } else {
        void *argp = 0;
        if (!SWIG_IsOK(SWIG_ConvertPtr(L, $input, &argp, $&descriptor, 0))) {
            SWIG_fail_ptr("$symname", $argnum, $&descriptor);
        }
        temp = std::move(*reinterpret_cast<std::function<Ret(##__VA_ARGS__)> *>(argp));
        $1 = &temp;
    }
%}

/* ---- Typecheck for overloaded functions ---- */
%typecheck(SWIG_TYPECHECK_POINTER,
           fragment="SWIG_Lua_std_function_support")
    std::function<Ret(##__VA_ARGS__)>,
    const std::function<Ret(##__VA_ARGS__)> &,
    std::function<Ret(##__VA_ARGS__)> *,
    std::function<Ret(##__VA_ARGS__)> &&
{
    if (lua_isfunction(L, $input)) {
        $1 = 1;
    } else {
        void *ptr = 0;
        $1 = lua_isuserdata(L, $input) &&
             SWIG_IsOK(SWIG_ConvertPtr(L, $input, &ptr, $descriptor(Name##_native_type *), 0));
    }
}

%enddef
