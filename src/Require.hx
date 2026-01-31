import Lua.State;

@:native("luarequire_NavigateResult")
enum abstract NavigateResult(Int) from Int to Int {
	@:native("NAVIGATE_SUCCESS")
	var SUCCESS:Int;
	@:native("NAVIGATE_AMBIGUOUS")
	var AMBIGUOUS:Int;
	@:native("NAVIGATE_NOT_FOUND")
	var NOT_FOUND:Int;
}

@:native("luarequire_WriteResult")
enum abstract WriteResult(Int) from Int to Int {
	@:native("WRITE_SUCCESS")
	var SUCCESS:Int;
	@:native("WRITE_BUFFER_TOO_SMALL")
	var BUFFER_TOO_SMALL:Int;
	@:native("WRITE_FAILURE")
	var FAILURE:Int;
}

@:buildXml("
	<files id='haxe'>
		<compilerflag value='-I${haxelib:hxluau}/luau/Require/Runtime/include/Luau'/>
	</files>")
@:headerCode('
#include <Require.h>

/**
 * This is a C++ wrapper around the C function luaopen_require().
 * It accepts a Haxe Dynamic context object to pass to luaopen_require().
 * @param L a pointer to the lua_State object
 * @param callbacks a pointer to a collection of callback functions.
 *                  Refer to the Haxe RequireCallbacks class.
 *                  FIXME Can this be typed to the Haxe class directly?
 * @param ctx The Haxe Dynamic context object to be called back from
 *            luaopen_require().
 * @return void
 */
void lua_openrequire_wrapper(lua_State *L, Dynamic callbacks, Dynamic ctx);
')
@:cppNamespaceCode('
#include <iostream>
#include <lua.h>
#include <RequireCallbacks.h>
#include <string.h>
#include <hx/StdString.h>

/**
 * Context struct to hold Haxe callbacks and context object.
 */
typedef struct luarequire_ctx {
    luarequire_ctx () {}
	~luarequire_ctx (){}

	hx::Object ** callbacks; // RequireCallbacks object
	hx::Object ** ctx;       // Requirer specific context object
} luarequire_ctx;

/**
 * Finalizer for the luarequire_ctx struct.
 * This is called when the Lua userdata is garbage collected and
 * it removes the GC roots for the Haxe objects and deletes them.
 * @param ud a pointer to the luarequire_ctx struct to finalize
 * @return void
 */
void gcroot_finalizer(void *ud) {
	std::cout << "gcroot_finalizer:entered" << std::endl;
	luarequire_ctx *ctxp = (static_cast<luarequire_ctx *>(ud));
	std::cout << "gcroot_finalizer:ctxp:" << (void *)ctxp << std::endl;

	auto ctx = (static_cast<hx::Object **>(ctxp->ctx));
    std::cout << "gcroot_finalizer:about to call delete root" << std::endl;
	std::cout << "gcroot_finalizer:root:" << (void *)(ctx) << std::endl;
	std::cout << "gcroot_finalizer:*root:" << (void *)(*ctx) << std::endl;
    GCRemoveRoot(ctx);
	delete ctx;

	auto callbacks = (static_cast<hx::Object **>(ctxp->callbacks));
    std::cout << "gcroot_finalizer:about to call delete callbacks" << std::endl;
	std::cout << "gcroot_finalizer:callbacks:" << (void *)(callbacks) << std::endl;
	std::cout << "gcroot_finalizer:*callbacks:" << (void *)(*callbacks) << std::endl;
	GCRemoveRoot(callbacks);
    delete callbacks;
}

/**
 * Write a string to a buffer.
 * @param contents the string contents to write
 * @param buffer the buffer to write to
 * @param bufferSize the size of the buffer
 * @param sizeOut pointer to size_t to receive the size written or
 * 				the size required if buffer is too small
 * @return luarequire_WriteResult indicating success, buffer too small,
 *         or failure
 */
static luarequire_WriteResult write(String contents, char* buffer, size_t bufferSize, size_t* sizeOut)
{
    if (!contents)
        return luarequire_WriteResult::WRITE_FAILURE;

	::hx::StdString sstr = ::hx::StdString(contents);
    size_t nullTerminatedSize = sstr.size() + 1;

    if (bufferSize < nullTerminatedSize)
    {
        *sizeOut = nullTerminatedSize;
        return luarequire_WriteResult::WRITE_BUFFER_TOO_SMALL;
    }

    *sizeOut = nullTerminatedSize;
    memcpy(buffer, sstr.c_str(), nullTerminatedSize);
    return luarequire_WriteResult::WRITE_SUCCESS;
}

/**
 * Returns whether requires are permitted from the given chunkname.
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @param requirer_chunkname the chunkname of the module performing the require
 * @return true if requires are allowed, false otherwise
 */
bool is_require_allowed(lua_State* L, void* ctx, const char* requirer_chunkname) {
	std::cout << "is_require_allowed called" << std::endl;
	luarequire_ctx *ctxp = (static_cast<luarequire_ctx *>(ctx));

	auto ctxRoot = *ctxp->ctx;
	auto cb = (static_cast<RequireCallbacks_obj *>(*ctxp->callbacks))->isRequireAllowed;
	std::cout << "is_require_allowed:cb:" << (void *)cb << std::endl;

	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);
	::String chunkname = ::String(requirer_chunkname);
	std::cout << "is_require_allowed:chunkname:" << chunkname << std::endl;
	std::cout << "is_require_allowed:cb:" << (void *)cb << std::endl;
    bool rv = cb(statePtr, ctxRoot, chunkname);
    std::cout << "is_require_allowed cb return " << rv << std::endl;
	return rv;
}

/**
 * Resets the internal state to point at the requirer module.
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @param requirer_chunkname the chunkname of the module performing the require
 * @return luarequire_NavigateResult indicating success, ambiguous, or not found
 */
luarequire_NavigateResult reset(lua_State* L, void* ctx, const char* requirer_chunkname) {
	std::cout << "reset called" << std::endl;
	luarequire_ctx *ctxp = (static_cast<luarequire_ctx *>(ctx));

	auto ctxRoot = *ctxp->ctx;
	std::cout << "reset: ctxRoot=" << (void *)ctxRoot << std::endl;

    auto cb = (static_cast<RequireCallbacks_obj *>(*ctxp->callbacks))->reset;

	// std::cout << "reset:ctxRoot:" << ctxRoot << std::endl;
	// std::cout << "reset:*ctxRoot:" << *ctxRoot << std::endl;

	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);
	::String chunkname = ::String(requirer_chunkname);

    Dynamic rvd = cb(statePtr, ctxRoot, chunkname);
	luarequire_NavigateResult rc = static_cast<luarequire_NavigateResult>(static_cast<int>(rvd));
    std::cout << "reset cb return " << rc << std::endl;
	return rc;
}

/**
 * Resets the internal state to point at an aliased module, given its exact
 * path from a configuration file. This function is only called when an
 * alias path cannot be resolved relative to its configuration file.
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @param path the exact path of the aliased module from a configuration file
 * @return luarequire_NavigateResult indicating success, ambiguous, or not found
 */
luarequire_NavigateResult jump_to_alias(lua_State* L, void* ctx, const char* path) {
	std::cout << "jump_to_alias called" << std::endl;
	return luarequire_NavigateResult::NAVIGATE_SUCCESS;
}

/**
 * Moves the internal state to the parent context.
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @return luarequire_NavigateResult indicating success, ambiguous, or not found
 */
luarequire_NavigateResult to_parent(lua_State* L, void* ctx) {
	std::cout << "to_parent called" << std::endl;
	luarequire_ctx *ctxp = (static_cast<luarequire_ctx *>(ctx));

	auto ctxRoot = *ctxp->ctx;
    auto cb = static_cast<RequireCallbacks_obj *>(*ctxp->callbacks)->to_parent;

	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);

    Dynamic rvd = cb(statePtr, ctxRoot);
	luarequire_NavigateResult rc = static_cast<luarequire_NavigateResult>(static_cast<int>(rvd));
    std::cout << "reset cb return " << rc << std::endl;
	return rc;
}

/**
 * Moves the internal state to the child context with the given name.
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @param name the name of the child context to move to
 * @return luarequire_NavigateResult indicating success, ambiguous, or not found
 */
luarequire_NavigateResult to_child(lua_State* L, void* ctx, const char* name) {
	std::cout << "to_child called" << std::endl;
	luarequire_ctx *ctxp = (static_cast<luarequire_ctx *>(ctx));

	auto ctxRoot = *ctxp->ctx;
    auto cb = static_cast<RequireCallbacks_obj *>(*ctxp->callbacks)->to_child;

	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);
	::String nameStr = ::String(name);

    Dynamic rvd = cb(statePtr, ctxRoot, nameStr);
	// FIXME - look and the new nightly haxe and marshaling of enums.
	luarequire_NavigateResult rc = static_cast<luarequire_NavigateResult>(static_cast<int>(rvd));
    std::cout << "to_child cb return " << rc << std::endl;
	return rc;
}

/**
 * Returns whether the context is currently pointing at a module.
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @return true if a module is present, false otherwise
 */
bool is_module_present(lua_State* L, void* ctx) {
	std::cout << "is_module_present called" << std::endl;

	luarequire_ctx *ctxp = (static_cast<luarequire_ctx *>(ctx));
	auto ctxRoot = *ctxp->ctx;
    auto cb = static_cast<RequireCallbacks_obj *>(*ctxp->callbacks)->is_module_present;

	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);

    bool rc = cb(statePtr, ctxRoot);
    std::cout << "is_module_present cb return " << rc << std::endl;
	return rc;
}

/**
 * Provides a chunkname for the current module. This will be accessible
 * through the debug library. This function is only called if
 * is_module_present returns true.
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @param buffer the buffer to write to
 * @param buffer_size the size of the buffer
 * @param size_out pointer to size_t to receive the size written or
 * 				the size required if buffer is too small
 * @return luarequire_WriteResult indicating success, buffer too small,
 */
luarequire_WriteResult get_chunkname(lua_State* L, void* ctx, char* buffer, size_t buffer_size, size_t* size_out) {
	std::cout << "get_chunkname called" << std::endl;

	luarequire_ctx *ctxp = (static_cast<luarequire_ctx *>(ctx));
	auto ctxRoot = *ctxp->ctx;
    auto cb = static_cast<RequireCallbacks_obj *>(*ctxp->callbacks)->get_chunkname;

	String chunkname = cb(L, ctxRoot);

    std::cout << "get_chunkname cb return " << chunkname << std::endl;
	return write(chunkname, buffer, buffer_size, size_out);
}

/**
 * Provides a loadname that identifies the current module and is passed to
 * load. This function is only called if is_module_present returns true.
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @param buffer the buffer to write to
 * @param buffer_size the size of the buffer
 * @param size_out pointer to size_t to receive the size written or
 * 			the size required if buffer is too small
 * @return luarequire_WriteResult indicating success, buffer too small,
 * 	   or failure
 */
luarequire_WriteResult get_loadname(lua_State* L, void* ctx, char* buffer,size_t buffer_size, size_t* size_out) {
	std::cout << "get_loadname called" << std::endl;

	luarequire_ctx *ctxp = (static_cast<luarequire_ctx *>(ctx));
	auto ctxRoot = *ctxp->ctx;
    auto cb = static_cast<RequireCallbacks_obj *>(*ctxp->callbacks)->get_loadname;

	String loadname = cb(L, ctxRoot);

    std::cout << "get_loadname cb return " << loadname << std::endl;
	return write(loadname, buffer, buffer_size, size_out);
}

/**
 * Provides a cache key representing the current module. This function is
 * only called if is_module_present returns true.
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @param buffer the buffer to write to
 * @param buffer_size the size of the buffer
 * @param size_out pointer to size_t to receive the size written or
 * 			the size required if buffer is too small
 * @return luarequire_WriteResult indicating success, buffer too small,
 * 	   or failure
 */
luarequire_WriteResult get_cache_key(lua_State* L, void* ctx, char* buffer, size_t buffer_size, size_t* size_out) {
	std::cout << "get_cache_key called" << std::endl;

	luarequire_ctx *ctxp = (static_cast<luarequire_ctx *>(ctx));
	auto ctxRoot = *ctxp->ctx;
    auto cb = static_cast<RequireCallbacks_obj *>(*ctxp->callbacks)->get_cache_key;

	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);

    // Dynamic rvd = cb(statePtr, ctxRoot, buffer, buffer_size, size_out);
	String key = cb(statePtr, ctxRoot);
	// luarequire_WriteResult rc = static_cast<luarequire_WriteResult>(static_cast<int>(rvd));
    std::cout << "get_cache_key cb return " << key << std::endl;
	return write(key, buffer, buffer_size, size_out);
	// std::cout << "size_out=" << size_out << std::endl;
	// return rc;
	// return luarequire_WriteResult::WRITE_SUCCESS;
}

/**
 * Returns whether a configuration file is present in the current context.
 * If not, require-by-string will call to_parent until either a
 * configuration file is present or NAVIGATE_FAILURE is returned (at root).
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @return true if a configuration file is present, false otherwise
 */
bool is_config_present(lua_State* L, void* ctx) {
	std::cout << "is_config_present called" << std::endl;
	return false;
}

/**
 * Provides the value of an alias from the configuration file in the
 * current context. This function is only called if is_config_present
 * returns true. If this function pointer is set, get_config must not be
 * set. Opting in to this function pointer enables parsing configuration
 * files internally.
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @param alias the alias to look up
 * @param buffer the buffer to write to
 * @param buffer_size the size of the buffer
 * @param size_out pointer to size_t to receive the size written or
 * 			the size required if buffer is too small
 * @return luarequire_WriteResult indicating success, buffer too small,
 *         or failure
 */
luarequire_WriteResult get_alias(lua_State* L, void* ctx, const char* alias, char* buffer, size_t buffer_size, size_t* size_out) {
	std::cout << "get_alias called" << std::endl;
	return luarequire_WriteResult::WRITE_SUCCESS;
}

/**
 * Provides the contents of the configuration file in the current context.
 * This function is only called if is_config_present returns true. If this
 * function pointer is set, get_alias must not be set. Opting in to this
 * function pointer enables parsing configuration files internally.
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @param buffer the buffer to write to
 * @param buffer_size the size of the buffer
 * @param size_out pointer to size_t to receive the size written or
 * 			the size required if buffer is too small
 * @return luarequire_WriteResult indicating success, buffer too small,
 *         or failure
 */
luarequire_WriteResult get_config(lua_State* L, void* ctx, char* buffer, size_t buffer_size, size_t* size_out) {
	std::cout << "get_config called" << std::endl;
	return luarequire_WriteResult::WRITE_SUCCESS;
}

/**
 * Executes the module and places the result on the stack. Returns the
 * number of results placed on the stack. Returning -1 directs the requiring
 * thread to yield. In this case, this thread should be resumed with the
 * module result pushed onto its stack.
 * @param L a pointer to the lua_State object
 * @param ctx a pointer to the luarequire_ctx struct
 * @param path the path of the module to load
 * @param chunkname the chunkname to use when loading the module
 * @param loadname the loadname to use when loading the module
 * @return the number of results placed on the stack, or -1 to yield
 */
int load(lua_State* L, void* ctx, const char* path, const char* chunkname, const char* loadname) {
	std::cout << "load called" << std::endl;

	luarequire_ctx *ctxp = (static_cast<luarequire_ctx *>(ctx));
	auto ctxRoot = Dynamic(ctxp->ctx);
    auto cb = static_cast<RequireCallbacks_obj *>(*ctxp->callbacks)->load;

	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);
	::String pathStr = ::String(path);
	::String chunknameStr = ::String(chunkname);
	::String loadnameStr = ::String(loadname);
	int rv = cb(statePtr, ctxRoot, pathStr, chunknameStr, loadnameStr);
	std::cout << "load cb return " << rv << std::endl;

	return rv;
}

/**
 * This initializes a luarequire_Configuration struct with function pointers
 * to the C++ functions defined above. These are jump functions that unpack
 * the Haxe context object and call the appropriate Haxe callback function.
 * 
 * @param config a pointer to the luarequire_Configuration struct to initialize
 * @return void
 */
void config_init(luarequire_Configuration* config) {
    config->is_require_allowed = is_require_allowed;
	config->reset = reset;
	config->jump_to_alias = jump_to_alias;
	config->to_parent = to_parent;
	config->to_child = to_child;
	config->is_module_present = is_module_present;
	config->is_config_present = is_config_present;
	config->get_chunkname = get_chunkname;
	config->get_loadname = get_loadname;
	config->get_cache_key = get_cache_key;
	config->get_alias = get_alias;
	// config->get_config = get_config;
	config->get_config = nullptr;
	config->load = load;
}

/**
 * Wrapper function to open the require module.
 * @param L a pointer to the lua_State object
 * @param callbacks a pointer to a collection of callback functions.
 *                  Refer to the Haxe RequireCallbacks class.
 * @param ctx The Haxe Dynamic context object to be called back from
 * 		  luaopen_require().
 * @return void
 */
void lua_openrequire_wrapper(lua_State *L, Dynamic callbacks, Dynamic ctx)
{
    // Allocate a userdata to hold the luarequire_ctx struct which will
	// hold both the callbacks and the context.
	luarequire_ctx *urctx = static_cast<luarequire_ctx *>(lua_newuserdatadtor(
		L,
		sizeof(luarequire_ctx),
		gcroot_finalizer
	));
	// FIXME This needs to handle memory alloc failures
	std::cout << "lua_openrequire_wrapper: about to root args" << std::endl;
	luarequire_ctx *reqCtx = new luarequire_ctx();
	std::cout << "lua_openrequire_wrapper: probably bad assignment" << std::endl;
	reqCtx->ctx = new hx::Object *{ctx.mPtr};
	std::cout << "lua_openrequire_wrapper: ctx.mPtr=" << (void *)ctx.mPtr << std::endl;

	GCAddRoot(reqCtx->ctx);
	reqCtx->callbacks = new hx::Object *{callbacks.mPtr};
	GCAddRoot(reqCtx->callbacks);
	std::cout << "lua_openrequire_wrapper: callbacks.mPtr=" << (void *)callbacks.mPtr << std::endl;

	*urctx = *reqCtx;
	std::cout << "lua_openrequire_wrapper: rooted args" << std::endl;

	// Store the ctxRoot in the registry. Use memory address as key
	// to avoid collisions.
	lua_pushlightuserdata(L, urctx);
    lua_insert(L, -2);
    lua_settable(L, LUA_REGISTRYINDEX);

	// Now unpack the config_init function pointer and call luaopen_require.
	// luarequire_Configuration_init config_init_fn = static_cast<luarequire_Configuration_init>(config_init.mPtr));
    luaopen_require(L, config_init, reqCtx);
}
')
@:keep
class RequireHidden {}

@:include("lua.h")
@:include("lualib.h")
@:include("luacode.h")
@:include("RequireHidden.h")
@:buildXml("
	<files id='haxe'>
		<compilerflag value='-I${haxelib:hxluau}/luau/Require/include'/>
	</files>
	<target id='haxe'>
        <lib name='${haxelib:hxluau}/luau/cmake/libLuau.Require.a'/>
        <lib name='${haxelib:hxluau}/luau/cmake/libLuau.Config.a'/>
	</target>")
extern class Require {
	/**
	 * Open all standard Lua libraries into the given state.
	 *
	 * @param L the Lua state
	 * @param callbacks a pointer to a collection of callback functions.
	 * @param ctx The Haxe Dynamic requirer context object to be passed back
	 *            on calls from the Luau require module.
	 * @return void
	 */
	@:native("lua_openrequire_wrapper")
	static function openrequire(L:State, callbacks:RequireCallbacks, ctx:Dynamic):Void;
}
