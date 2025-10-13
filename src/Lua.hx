package;

@:include("lua.h")
@:buildXml("
	<files id='haxe'>
		<compilerflag value='-I${haxelib:hxluau}/luau/VM/include'/>
	</files>")
@:native("lua_State")
extern class NativeState {}

typedef State = cpp.Pointer<NativeState>;

private abstract CString(cpp.ConstCharStar) from cpp.ConstCharStar to cpp.ConstCharStar {
	@:from static inline function fromString(s:String):CString {
		return (s : cpp.ConstCharStar);
	}

	@:to inline function toString():String {
		return (this : String);
	}
}

/**
 * Lua status codes.
 */
abstract LuaStatus(Int) from Int to Int {
	@:native("LUA_OK")
	public static var OK:Int;
	@:native("LUA_YIELD")
	public static var YIELD:Int;
	@:native("LUA_ERRRUN")
	public static var ERRRUN:Int;
	@:native("LUA_ERRSYNTAX")
	public static var ERRSYNTAX:Int;
	@:native("LUA_ERRMEM")
	public static var ERRMEM:Int;
	@:native("LUA_ERRERR")
	public static var ERRERR:Int;
	@:native("LUA_BREAK")
	public static var BREAK:Int;
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
extern class Lua {
	// option for multiple returns in 'lua_pcall' and 'lua_call'
	@:native("LUA_MULTRET")
	static var MULTRET:Int;

	/**
	 * Pseudo indices
	 */
	/**
	 * Registry index.
	 */
	@:native('LUA_REGISTRYINDEX')
	static var REGISTRYINDEX:Int;

	/**
	 * Environment index.
	 */
	@:native('LUA_ENVIRONINDEX')
	static var ENVIRONINDEX:Int;

	/**
	 * Globals index.
	 */
	@:native('LUA_GLOBALSINDEX')
	static var GLOBALSINDEX:Int;

	/**
	 * Get the upvalue index.
	 *
	 * @param i The upvalue index.
	 * @return The index of the upvalue.
	 */
	@:native('lua_upvalueindex')
	static function upvalueindex(i:Int):Int;

	@:native("lua_ispseudo")
	static function ispseudo(i:Int):Int;

	@:native("luaL_newstate")
	static function newstate():State;

	@:native("luau_compile")
	static function luau_compile(source:cpp.ConstCharStar, size:cpp.SizeT, options:Null<Dynamic>, bytecodeSize:cpp.Star<cpp.SizeT>):cpp.ConstCharStar;

	@:native("luau_load")
	static function luau_load(L:State, name:String, bytecode:cpp.ConstCharStar, bytecodeSize:cpp.SizeT, mode:Int):Int;

	@:native("lua_tolstring")
	static function tolstring(L:State, idx:Int, len:cpp.Star<cpp.SizeT>):CString;

	static inline function tostring(L:State, idx:Int):CString {
		return tolstring(L, idx, null);
	}

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
