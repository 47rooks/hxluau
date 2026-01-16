import Lua.CSizeT;
import Lua.NativeState;
import Lua.Ref;
import Lua.State;
import Types.CString;

@:native("luarequire_NavigateResult")
extern enum abstract NavigateResult(Int) from Int to Int {
	@:native("NAVIGATE_SUCCESS")
	public static var SUCCESS:Int;
	@:native("NAVIGATE_AMBIGUOUS")
	public static var AMBIGUOUS:Int;
	@:native("NAVIGATE_NOT_FOUND")
	public static var NOT_FOUND:Int;
}

@:native("luarequire_WriteResult")
extern enum abstract WriteResult(Int) from Int to Int {
	@:native("WRITE_SUCCESS")
	public static var SUCCESS:Int;
	@:native("WRITE_BUFFER_TOO_SMALL")
	public static var BUFFER_TOO_SMALL:Int;
	@:native("WRITE_FAILURE")
	public static var FAILURE:Int;
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
	public var reset:(L:State, ctx:cpp.Star<Dynamic>, requirerChunkname:CString) -> NavigateResult;

	@:native("jump_to_alias")
	public var jump_to_alias:(L:State, ctx:cpp.Star<Dynamic>, path:CString) -> NavigateResult;

	@:native("to_parent")
	public var to_parent:(L:State, ctx:cpp.Star<Dynamic>) -> NavigateResult;

	@:native("to_child")
	public var to_child:(L:State, ctx:cpp.Star<Dynamic>, name:CString) -> NavigateResult;

	@:native("is_module_present")
	public var is_module_present:(L:State, ctx:cpp.Star<Dynamic>) -> Bool;

	@:native("get_chunkname")
	public var get_chunkname:(L:State, ctx:cpp.Star<Dynamic>, buffer:cpp.Star<cpp.Char>, bufferSize:CSizeT, sizeOut:Ref<CSizeT>) -> WriteResult;

	@:native("get_loadname")
	public var get_loadname:(L:State, ctx:cpp.Star<Dynamic>, buffer:cpp.Star<cpp.Char>, bufferSize:CSizeT, sizeOut:Ref<CSizeT>) -> WriteResult;

	@:native("get_cache_key")
	public var get_cache_key:(L:State, ctx:cpp.Star<Dynamic>, buffer:cpp.Star<cpp.Char>, bufferSize:CSizeT, sizeOut:Ref<CSizeT>) -> WriteResult;

	@:native("is_config_present")
	public var is_config_present:(L:State, ctx:cpp.Star<Dynamic>) -> Bool;

	@:native("get_alias")
	public var get_alias:(L:State, ctx:cpp.Star<Dynamic>, alias:CString, buffer:cpp.Star<cpp.Char>, bufferSize:CSizeT, sizeOut:Ref<CSizeT>) -> WriteResult;

	@:native("get_config")
	public var get_config:(L:State, ctx:cpp.Star<Dynamic>, buffer:cpp.Star<cpp.Char>, bufferSize:CSizeT, sizeOut:Ref<CSizeT>) -> WriteResult;

	@:native("load")
	public var load:(L:State, ctx:cpp.Star<Dynamic>, path:CString, chunkname:CString, loadname:CString) -> Int;

	@:native("luarequire_Configuration")
	public static function create():Configuration;
}

@:cppNamespaceCode('
#include <iostream>
#include <lua.h>
#include <Require.h>

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

void lua_openrequire_wrapper(lua_State *L, luarequire_Configuration_init config_init, Dynamic ctx)
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
void lua_openrequire_wrapper(lua_State *L, luarequire_Configuration_init config_init, Dynamic ctx);
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
	static function openrequire(L:State, config_init:Dynamic, ctx:Dynamic):Void;
}
