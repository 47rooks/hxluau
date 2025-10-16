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

typedef CSizeT = cpp.SizeT;
private typedef Ref<T> = cpp.Star<T>;

private abstract Bytecode(cpp.ConstCharStar) from cpp.ConstCharStar to cpp.ConstCharStar {
	@:from static inline function fromPointer(p:cpp.ConstCharStar):Bytecode {
		return p;
	}

	@:to inline function toPointer():cpp.ConstCharStar {
		return this;
	}
}

/**
 * An opaque struct to hold compiled bytecode and its size.
 * Callers must not modify or free the contents.
 */
class Code {
	public var code:cpp.ConstCharStar;

	public var size:Int;

	public function new() {}
}

@:include("luacode.h")
@:buildXml("
	<files id='haxe'>
		<compilerflag value='-I${haxelib:hxluau}/luau/Compiler/include'/>
	</files>")
@:native("lua_CompileOptions")
@:structInit()
extern class CompileOptions {}

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

	// FIXME the options type is complex and needs to be full externed
	@:native("luau_compile")
	static function _compile(source:CString, size:CSizeT, options:cpp.Pointer<CompileOptions>, bytecodeSize:cpp.Pointer<CSizeT>):cpp.ConstCharStar;

	static inline function compile(source:CString, size:CSizeT, ?options:CompileOptions):Code {
		var bytecodeSize:CSizeT = 0;
		var bytecode = _compile(source, size, cpp.Pointer.addressOf(options), cpp.Pointer.addressOf(bytecodeSize));
		var rv = new Code();
		rv.code = bytecode;
		rv.size = bytecodeSize;
		return rv;
	};

	@:native("luau_load")
	static function _load(L:State, name:String, bytecode:Bytecode, bytecodeSize:CSizeT, mode:Int):Int;

	static inline function load(L:State, name:String, bytecode:Code, mode:Int):Int {
		return _load(L, name, bytecode.code, bytecode.size, mode);
	}

	@:native("lua_tolstring")
	static function tolstring(L:State, idx:Int, len:Ref<CSizeT>):CString;

	@:native("lua_tostring")
	static function tostring(L:State, idx:Int):CString;

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
	static function getglobal(L:State, s:CString):Int;

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
