import Lua.CSizeT;
import Lua.NativeState;
import Lua.Ref;
import Lua.State;
import Types.CString;

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

@:include("Require.h")
@:buildXml("
	<files id='haxe'>
		<compilerflag value='-I${haxelib:hxluau}/luau/Require/Runtime/include/Luau'/>
	</files>")
@:native("luarequire_Configuration")
@:structAccess
extern class Configuration {
	@:native("is_require_allowed")
	public var is_require_allowed:(L:cpp.RawPointer<NativeState>, ctx:cpp.RawPointer<cpp.Void>, requirerChunkname:CString) -> Bool;

	@:native("reset")
	public var reset:(L:State, ctx:cpp.RawPointer<cpp.Void>, requirerChunkname:CString) -> NavigateResult;

	@:native("jump_to_alias")
	public var jump_to_alias:(L:State, ctx:cpp.RawPointer<cpp.Void>, path:CString) -> NavigateResult;

	@:native("to_parent")
	public var to_parent:(L:State, ctx:cpp.RawPointer<cpp.Void>) -> NavigateResult;

	@:native("to_child")
	public var to_child:(L:State, ctx:cpp.RawPointer<cpp.Void>, name:CString) -> NavigateResult;

	@:native("is_module_present")
	public var is_module_present:(L:State, ctx:cpp.RawPointer<cpp.Void>) -> Bool;

	@:native("get_chunkname")
	public var get_chunkname:(L:State, ctx:cpp.RawPointer<cpp.Void>, buffer:cpp.RawPointer<cpp.Char>, bufferSize:CSizeT,
		sizeOut:cpp.RawPointer<CSizeT>) -> WriteResult;

	@:native("get_loadname")
	public var get_loadname:(L:State, ctx:cpp.RawPointer<cpp.Void>, buffer:cpp.RawPointer<cpp.Char>, bufferSize:CSizeT,
		sizeOut:cpp.RawPointer<CSizeT>) -> WriteResult;

	@:native("get_cache_key")
	public var get_cache_key:(L:State, ctx:cpp.RawPointer<cpp.Void>, buffer:cpp.RawPointer<cpp.Char>, bufferSize:CSizeT,
		sizeOut:cpp.RawPointer<CSizeT>) -> WriteResult;

	@:native("is_config_present")
	public var is_config_present:(L:State, ctx:cpp.RawPointer<cpp.Void>) -> Bool;

	@:native("get_alias")
	public var get_alias:(L:State, ctx:cpp.RawPointer<cpp.Void>, alias:CString, buffer:cpp.Star<cpp.Char>, bufferSize:CSizeT,
		sizeOut:Ref<CSizeT>) -> WriteResult;

	@:native("get_config")
	public var get_config:(L:State, ctx:cpp.RawPointer<cpp.Void>, buffer:cpp.RawPointer<cpp.Char>, bufferSize:CSizeT,
		sizeOut:cpp.RawPointer<CSizeT>) -> WriteResult;

	@:native("load")
	public var load:(L:State, ctx:cpp.RawPointer<cpp.Void>, path:CString, chunkname:CString, loadname:CString) -> Int;

	@:native("luarequire_Configuration")
	public static function create():Configuration;
}

@:cppNamespaceCode('
#include <iostream>
#include <lua.h>
#include <Require.h>
#include <RequireCtx.h>
#include <string.h>
#include <hx/StdString.h>

/*
int callback(lua_State *L)
{
	// std::cout << "callback:entered" << std::endl;
    auto root = *(static_cast<hx::Object ***>(lua_touserdatatagged(L,
								  	 			lua_upvalueindex(1), 1)));
    // std::cout << "callback:root:" << root << std::endl;
    // std::cout << "callback:*root:" << *root << std::endl;
    auto cb = Dynamic(*root);
    // std::cout << "about call cb()" << std::endl;
	// std::cout << "callback:L:" << L << std::endl;
	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);
    int rv = cb(statePtr);
    return rv;
}
*/
void gcroot_finalizer (void *ud) {
	// std::cout << "gcroot_finalizer:entered" << std::endl;
	auto root = *(static_cast<hx::Object ***>(ud));
    GCRemoveRoot(root);
    // std::cout << "gcroot_finalizer:about to call delete root" << std::endl;
	// std::cout << "gcroot_finalizer:root:" << root << std::endl;
    delete root;
}

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

// Returns whether requires are permitted from the given chunkname.
bool is_require_allowed(lua_State* L, void* ctx, const char* requirer_chunkname) {
	std::cout << "is_require_allowed called" << std::endl;
	RequireCtx_obj *ctxRoot = *(static_cast<RequireCtx_obj **>(ctx));
    auto cb = ctxRoot->is_require_allowed;
    // std::cout << "callback:root:" << root << std::endl;
    // std::cout << "callback:*root:" << *root << std::endl;
    // auto cb = Dynamic(*root);
    // std::cout << "about call cb()" << std::endl;
	// std::cout << "callback:L:" << L << std::endl;
	auto data = &(ctxRoot->data);
	// auto data = *(static_cast<RequireCtxData_obj **> (*ctxRoot)->data.mPtr));
    // std::cout << "data:" << data << std::endl;
	// hx::Object **dataCtx = new hx::Object *{ctxRoot->data};
	// hx::Object **dataCtx  = <hx::Object>(ctxRoot->data);
	// std::cout << "number of calls=" << static_cast<RequireCtxData*>(data->mPtr).number_of_calls;
	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);
	::String chunkname = ::String(requirer_chunkname);
    bool rv = cb(statePtr, ctxRoot, chunkname);
    std::cout << "is_require_allowed cb return " << rv << std::endl;
	return rv;
}

// Resets the internal state to point at the requirer module.
luarequire_NavigateResult reset(lua_State* L, void* ctx, const char* requirer_chunkname) {
	std::cout << "reset called" << std::endl;
	RequireCtx_obj *ctxRoot = *(static_cast<RequireCtx_obj **>(ctx));
    auto cb = ctxRoot->reset;

	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);
	::String chunkname = ::String(requirer_chunkname);

    Dynamic rvd = cb(statePtr, ctxRoot, chunkname);
	luarequire_NavigateResult rc = static_cast<luarequire_NavigateResult>(static_cast<int>(rvd));
    std::cout << "reset cb return " << rc << std::endl;
	return rc;
}

// Resets the internal state to point at an aliased module, given its exact
// path from a configuration file. This function is only called when an
// alias path cannot be resolved relative to its configuration file.
luarequire_NavigateResult jump_to_alias(lua_State* L, void* ctx, const char* path) {
	std::cout << "jump_to_alias called" << std::endl;
	return luarequire_NavigateResult::NAVIGATE_SUCCESS;
}

// Navigates through the context by making mutations to the internal state.
luarequire_NavigateResult to_parent(lua_State* L, void* ctx) {
	std::cout << "to_parent called" << std::endl;
	RequireCtx_obj *ctxRoot = *(static_cast<RequireCtx_obj **>(ctx));
    auto cb = ctxRoot->to_parent;

	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);

    Dynamic rvd = cb(statePtr, ctxRoot);
	luarequire_NavigateResult rc = static_cast<luarequire_NavigateResult>(static_cast<int>(rvd));
    std::cout << "reset cb return " << rc << std::endl;
	return rc;
}

luarequire_NavigateResult to_child(lua_State* L, void* ctx, const char* name) {
	std::cout << "to_child called" << std::endl;

	RequireCtx_obj *ctxRoot = *(static_cast<RequireCtx_obj **>(ctx));
    auto cb = ctxRoot->to_child;

	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);
	::String nameStr = ::String(name);

    Dynamic rvd = cb(statePtr, ctxRoot, nameStr);
	// FIXME - look and the new nightly haxe and marshaling of enums.
	luarequire_NavigateResult rc = static_cast<luarequire_NavigateResult>(static_cast<int>(rvd));
    std::cout << "to_child cb return " << rc << std::endl;
	return rc;
}

// Returns whether the context is currently pointing at a module.
bool is_module_present(lua_State* L, void* ctx) {
	std::cout << "is_module_present called" << std::endl;
	RequireCtx_obj *ctxRoot = *(static_cast<RequireCtx_obj **>(ctx));
    auto cb = ctxRoot->is_module_present;

	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);

    bool rc = cb(statePtr, ctxRoot);
    std::cout << "is_module_present cb return " << rc << std::endl;
	return rc;
}

// Provides a chunkname for the current module. This will be accessible
// through the debug library. This function is only called if
// is_module_present returns true.
luarequire_WriteResult get_chunkname(lua_State* L, void* ctx, char* buffer, size_t buffer_size, size_t* size_out) {
	std::cout << "get_chunkname called" << std::endl;

	RequireCtx_obj *ctxRoot = *(static_cast<RequireCtx_obj **>(ctx));
    auto cb = ctxRoot->get_chunkname;

	String chunkname = cb(L, ctxRoot);

    std::cout << "get_chunkname cb return " << chunkname << std::endl;
	return write(chunkname, buffer, buffer_size, size_out);
}

// Provides a loadname that identifies the current module and is passed to
// load. This function is only called if is_module_present returns true.
luarequire_WriteResult get_loadname(lua_State* L, void* ctx, char* buffer, size_t buffer_size, size_t* size_out) {
	std::cout << "get_loadname called" << std::endl;

	RequireCtx_obj *ctxRoot = *(static_cast<RequireCtx_obj **>(ctx));
    auto cb = ctxRoot->get_loadname;

	String loadname = cb(L, ctxRoot);

    std::cout << "get_loadname cb return " << loadname << std::endl;
	return write(loadname, buffer, buffer_size, size_out);
}

// Provides a cache key representing the current module. This function is
// only called if is_module_present returns true.
luarequire_WriteResult get_cache_key(lua_State* L, void* ctx, char* buffer, size_t buffer_size, size_t* size_out) {
	std::cout << "get_cache_key called" << std::endl;

	RequireCtx_obj *ctxRoot = *(static_cast<RequireCtx_obj **>(ctx));
    auto cb = ctxRoot->get_cache_key;

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

// Returns whether a configuration file is present in the current context.
// If not, require-by-string will call to_parent until either a
// configuration file is present or NAVIGATE_FAILURE is returned (at root).
bool is_config_present(lua_State* L, void* ctx) {
	std::cout << "is_config_present called" << std::endl;
	return false;
}

// Parses the configuration file in the current context for the given alias
// and returns its value or WRITE_FAILURE if not found. This function is
// only called if is_config_present returns true. If this function pointer
// is set, get_config must not be set. Opting in to this function pointer
// disables parsing configuration files internally and can be used for finer
// control over the configuration file parsing process.
luarequire_WriteResult get_alias(lua_State* L, void* ctx, const char* alias, char* buffer, size_t buffer_size, size_t* size_out) {
	std::cout << "get_alias called" << std::endl;
	return luarequire_WriteResult::WRITE_SUCCESS;
}

// Provides the contents of the configuration file in the current context.
// This function is only called if is_config_present returns true. If this
// function pointer is set, get_alias must not be set. Opting in to this
// function pointer enables parsing configuration files internally.
luarequire_WriteResult get_config(lua_State* L, void* ctx, char* buffer, size_t buffer_size, size_t* size_out) {
	std::cout << "get_config called" << std::endl;
	return luarequire_WriteResult::WRITE_SUCCESS;
}

// Executes the module and places the result on the stack. Returns the
// number of results placed on the stack. Returning -1 directs the requiring
// thread to yield. In this case, this thread should be resumed with the
// module result pushed onto its stack.
int load(lua_State* L, void* ctx, const char* path, const char* chunkname, const char* loadname) {
	std::cout << "load called" << std::endl;

	RequireCtx_obj *ctxRoot = *(static_cast<RequireCtx_obj **>(ctx));
    auto cb = ctxRoot->load;

	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);
	::String pathStr = ::String(path);
	::String chunknameStr = ::String(chunkname);
	::String loadnameStr = ::String(loadname);
	int rv = cb(statePtr, ctxRoot, pathStr, chunknameStr, loadnameStr);
	std::cout << "load cb return " << rv << std::endl;

	return rv;
}

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

// void lua_openrequire_wrapper(lua_State *L, luarequire_Configuration_init config_init, Dynamic ctx)
void lua_openrequire_wrapper(lua_State *L, Dynamic ctx)
{
    hx::Object ** *ud = static_cast<hx::Object ***>(lua_newuserdatadtor(
        L,
        sizeof(hx::Object **),
        gcroot_finalizer
    ));
    hx::Object **ctxRoot = new hx::Object *{ctx.mPtr};
    GCAddRoot(ctxRoot);
    // std::cout << "wrapper:cb.mPtr:" << cb.mPtr << std::endl;
    // std::cout << "wrapper:root:" << root << std::endl;
    // std::cout << "wrapper:*root:" << *root << std::endl;
	*ud = ctxRoot;
	
	// Store the ctxRoot in the registry. Use memory address as key
	// to avoid collisions.
	lua_pushlightuserdata(L, ud);
    lua_insert(L, -2);
    lua_settable(L, LUA_REGISTRYINDEX);

    luaopen_require(L, config_init, ctxRoot);
}
')
@:headerCode('
#include <Require.h>

/// @brief This is a C++ wrapper around the C function luaopen_require().
/// It accepts a Haxe Dynamic context object to pass to luaopen_require().
/// @param *L a pointer to the lua_State object
/// @param config_init a pointer to a function to call to initialize the
///        the requirer callback table.
/// @param ctx The Haxe Dynamic context object to be called back from
///           luaopen_require().
// void lua_openrequire_wrapper(lua_State *L, luarequire_Configuration_init config_init, Dynamic ctx);
void lua_openrequire_wrapper(lua_State *L, Dynamic ctx);
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
	 */
	@:native("lua_openrequire_wrapper")
	static function openrequire(L:State, ctx:Dynamic):Void;
}
