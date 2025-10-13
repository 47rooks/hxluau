package;

@:include("lua.h")
@:buildXml("
	<files id='haxe'>
	<compilerflag value='-I${haxelib:hxluau}/luau/VM/include'/>
	</files>")
@:native("lua_State")
extern class NativeState {}

typedef State = cpp.Pointer<NativeState>;

/**
 * Lua status codes.
 * FIXME This is defining the int values to match luau rather 
 *       that relying on their values. Need to figure out how to
 *       extern to the lua_Status enum directly.
 */
@:native("lua_Status")
enum abstract LuaStatus(Int) from Int to Int {
	var LUA_OK;
	var LUA_YIELD;
	var LUA_ERRRUN;
	var LUA_ERRSYNTAX;
	var LUA_ERRMEM;
	var LUA_ERRERR;
	var LUA_BREAK;
}

@:include("lua.h")
@:include("lualib.h")
@:include("luacode.h")
@:buildXml("
	<files id='haxe'>
	<compilerflag value='-I${haxelib:hxluau}/luau/VM/include'/>
	<compilerflag value='-I${haxelib:hxluau}/luau/Compiler/include'/>
	</files>
	<target id='haxe'>
	<lib name='${haxelib:hxluau}/luau/cmake/libLuau.VM.a'/>
	<lib name='${haxelib:hxluau}/luau/cmake/libLuau.Compiler.a'/>
	<lib name='${haxelib:hxluau}/luau/cmake/libLuau.Ast.a'/>
	</target>")
extern class Luau {
	@:native("luaL_newstate")
	static function newstate():State;

	@:native("luau_compile")
	static function luau_compile(source:cpp.ConstCharStar, size:cpp.SizeT, options:Null<Dynamic>, bytecodeSize:cpp.Star<cpp.SizeT>):cpp.ConstCharStar;

	@:native("luau_load")
	static function luau_load(L:State, name:String, bytecode:cpp.ConstCharStar, bytecodeSize:cpp.SizeT, mode:Int):Int;

	@:native("lua_tostring")
	static function tostring(L:State, idx:Int):cpp.ConstCharStar;

	/**
	 * Pop n elements from the stack.
	 *
	 * @param L The Lua state.
	 * @param n The number of elements to pop.
	 */
	@:native('lua_pop')
	static function pop(L:State, n:Int):Void;

	/**
	 * Call a function.
	 *
	 * @param L The Lua state.
	 * @param nargs The number of arguments.
	 * @param nresults The number of results.
	 */
	@:native('lua_call')
	static function call(L:State, nargs:Int, nresults:Int):Void;

	/**
	 * Get a global value.
	 *
	 * @param L The Lua state.
	 * @param s The name of the global.
	 * @return The result of the operation.
	 */
	@:native('lua_getglobal')
	static function getglobal(L:State, s:cpp.ConstCharStar):Int;

	/**
	 * Check if a value is a number.
	 *
	 * @param L The Lua state.
	 * @param idx The index of the value to check.
	 * @return 1 if the value is a number, 0 otherwise.
	 */
	@:native('lua_isnumber')
	static function isnumber(L:State, idx:Int):Int;

	/**
	 * Convert a value to a number.
	 *
	 * @param L The Lua state.
	 * @param idx The index of the value.
	 * @return The number.
	 */
	@:native('lua_tonumber')
	static function tonumber(L:State, idx:Int):Float;
}
