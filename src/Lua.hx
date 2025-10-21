package;

import haxe.ds.Vector;

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

extern enum abstract LuaDefines(Int) from Int to Int {
	@:native("LUA_VECTOR_SIZE")
	var VECTOR_SIZE:Int;

	@:native("LUA_TNONE")
	var NONE:Int;
}

/**
 * Lua thread status codes.
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

abstract LuaCoStatus(Int) from Int to Int {
	@:native("LUA_CORUN")
	public static var CORUN:Int;
	@:native("LUA_COSUS")
	public static var COSUS:Int;
	@:native("LUA_CONOR")
	public static var CONOR:Int;
	@:native("LUA_COFIN")
	public static var COFIN:Int;
	@:native("LUA_COERR")
	public static var COERR:Int;
}

typedef LuaCFunction = cpp.Callable<State->Int>;
typedef LuaCcontinuation = cpp.Callable<(State, Int) -> Int>;

// typedef for memory allocation functions
typedef LuaAlloc = cpp.Callable<(cpp.Pointer<Void>, cpp.Pointer<Void>, CSizeT, CSizeT) -> cpp.Pointer<Void>>;

/**
 * basic type
 * LUA_TNONE is in LuaDefines as it outside the enum in Luau
 */
abstract LuaType(Int) from Int to Int {
	@:native("LUA_TNIL")
	public static var NIL:Int;
	@:native("LUA_TBOOLEAN")
	public static var BOOLEAN:Int;
	@:native("LUA_TLIGHTUSERDATA")
	public static var LIGHTUSERDATA:Int;
	@:native("LUA_TNUMBER")
	public static var NUMBER:Int;
	@:native("LUA_TVECTOR")
	public static var VECTOR:Int;
	@:native("LUA_TSTRING")
	public static var STRING:Int;
	@:native("LUA_TTABLE")
	public static var TABLE:Int;
	@:native("LUA_TFUNCTION")
	public static var FUNCTION:Int;
	@:native("LUA_TUSERDATA")
	public static var USERDATA:Int;
	@:native("LUA_TTHREAD")
	public static var THREAD:Int;
	@:native("LUA_TBUFFER")
	public static var BUFFER:Int;
	@:native("LUA_TPROTO")
	public static var PROTO:Int;
	@:native("LUA_TUPVAL")
	public static var UPVAL:Int;
	@:native("LUA_TDEADKEY")
	public static var DEADKEY:Int;
	@:native("LUA_T_COUNT")
	public static var COUNT:Int;
}

/**
 * floating point type
 * This maps to the Haxe Float which is a double precision 64 bit float.
 */
@:native("lua_Number")
@:scalar
@:coreType
@:notNull
extern abstract LuaNumber from Float to Float {}

/**
 * signed integer type
 * This maps to a C++ int type which is a 32 bit integer, for
 * the common case. Note, the Lua language itself does not have
 * an integer type, only a number type (floating point). This is
 * only used to allow host languages to push integers into the VM, or
 * get them back.
 */
@:native("lua_Integer")
@:scalar
@:coreType
@:notNull
extern abstract LuaInteger from Int to Int {}

/**
 * unsigned integer type
 * FIXME - determine if this should be 32 or 64 bit
 * The more I think about this the more I think I need some
 * C++ based boundary testing to figure out what happens as
 * these type conversion occur.
 */
@:native("lua_Unsigned")
@:scalar
@:coreType
@:notNull
extern abstract LuaUnsigned from cpp.UInt32 to cpp.UInt32 {}

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

	/*
	 * State manipulation
	 */
	/**
	 * Create a new Lua state.
	 * @return The new Lua state.
	 */
	@:native("luaL_newstate")
	static function newstate():State;

	// FIXME This is the proper C signature but it would only be useful
	//       for targets that support memory allocation like this.
	// static function newstate(f:LuaAlloc, ud:cpp.RawPointer<cpp.Void>):State;
	// @:native("luaL_newstate")
	// static function newstate(f:LuaAlloc, ud:cpp.RawPointer<cpp.Void>):State;

	/**
	 * Close a Lua state.
	 * @param L the state to close
	 */
	@:native("lua_close")
	static function close(L:State):Void;

	@:native("lua_newthread")
	static function newthread(L:State):State;

	@:native("lua_mainthread")
	static function mainthread(L:State):State;

	@:native("lua_resetthread")
	static function resetthread(L:State):Void;

	@:native("lua_isthreadreset")
	static function isthreadreset(L:State):Int;

	/*
	 * Basic stack manipulation
	 */
	@:native("lua_absindex")
	static function absindex(L:State, idx:Int):Int;

	@:native("lua_gettop")
	static function gettop(L:State):Int;

	@:native("lua_settop")
	static function settop(L:State, idx:Int):Void;

	@:native("lua_pushvalue")
	static function pushvalue(L:State, idx:Int):Void;

	@:native("lua_remove")
	static function remove(L:State, idx:Int):Void;

	@:native("lua_insert")
	static function insert(L:State, idx:Int):Void;

	@:native("lua_replace")
	static function replace(L:State, idx:Int):Void;

	@:native("lua_checkstack")
	static function checkstack(L:State, sz:Int):Int;

	@:native("lua_rawcheckstack")
	static function rawcheckstack(L:State, sz:Int):Void;

	/**
	 * Move a stack element from one state to another.
	 * 
	 * Note, that if the states are related by one having been created as a
	 * copy of the other using lua_newthread, for example the value will not
	 * appear to move.
	 * 
	 * @param from the source state
	 * @param to the destination state
	 * @param n the index of the element to move
	 */
	@:native("lua_xmove")
	static function xmove(from:State, to:State, n:Int):Void;

	/**
	 * Move a stack element from one state to another by pushing it.
	 * 
	 * As with `xmove`, if the states are related by one having been created as
	 * a copy of the other using lua_newthread, for example the value will not
	 * appear to move.
	 * 
	 * @param from the source state
	 * @param to the destination state
	 * @param idx the index of the element to move
	 */
	@:native("lua_xpush")
	static function xpush(from:State, to:State, idx:Int):Void;

	/*
	 * Access functions (stack -> C)
	 */
	/**
	 * Check if a value is a number.
	 *
	 * @param L The Lua state.
	 * @param idx The index of the value to check.
	 * @return 1 if the value is a number, 0 otherwise.
	 */
	@:native('lua_isnumber')
	static function isnumber(L:State, idx:Int):Int;

	@:native("lua_isstring")
	static function isstring(L:State, idx:Int):Int;

	@:native("lua_iscfunction")
	static function iscfunction(L:State, idx:Int):Int;

	@:native("lua_isLfunction")
	static function isLfunction(L:State, idx:Int):Int;

	@:native("lua_isuserdata")
	static function isuserdata(L:State, idx:Int):Int;

	@:native("lua_type")
	static function type(L:State, idx:Int):Int;

	@:native("lua_typename")
	static function typename(L:State, tp:Int):CString;

	@:native("lua_equal")
	static function equal(L:State, idx1:Int, idx2:Int):Int;

	@:native("lua_rawequal")
	static function rawequal(L:State, idx1:Int, idx2:Int):Int;

	@:native("lua_lessthan")
	static function lessthan(L:State, idx1:Int, idx2:Int):Int;

	@:native("lua_tonumberx")
	static function tonumberx(L:State, idx:Int, isnum:Ref<Int>):Float;

	@:native("lua_tointegerx")
	static function tointegerx(L:State, idx:Int, isnum:Ref<Int>):Int;

	@:native("lua_tounsignedx")
	static function tounsignedx(L:State, idx:Int, isnum:Ref<Int>):UInt;

	@:native("lua_tounsigned")
	static function tounsigned(L:State, idx:Int):UInt;

	@:native("lua_tovector")
	static function _tovector(L:State, idx:Int):cpp.ConstPointer<cpp.Float32>;

	static inline function tovector(L:State, idx:Int):Vector<Float> {
		var p = _tovector(L, idx);
		var rv:Vector<Float> = null;
		if (p != null) {
			if (LuaDefines.VECTOR_SIZE == 3) {
				rv = new Vector<Float>(3);
			} else {
				rv = new Vector<Float>(4);
			}
			rv[0] = p.get_value();
			p.inc();
			rv[1] = p.get_value();
			p.inc();
			rv[2] = p.get_value();
			if (LuaDefines.VECTOR_SIZE == 4) {
				p.inc();
				rv[3] = p.get_value();
			}
			return rv;
		}
		return null;
	}
	@:native("lua_toboolean")
	static function toboolean(L:State, idx:Int):Int;

	@:native("lua_tolstring")
	static function tolstring(L:State, idx:Int, len:Ref<CSizeT>):CString;

	@:native("lua_tostringatom")
	static function tostringatom(L:State, idx:Int, atom:Ref<Int>):CString;

	@:native("lua_tolstringatom")
	static function tolstringatom(L:State, idx:Int, len:Ref<CSizeT>, atom:Ref<Int>):CString;

	@:native("lua_namecallatom")
	static function namecallatom(L:State, atom:Ref<Int>):CString;

	@:native("lua_objlen")
	static function objlen(L:State, idx:Int):Int;

	@:native("lua_tocfunction")
	static function tocfunction(L:State, idx:Int):LuaCFunction;

	@:native("lua_tolightuserdata")
	static function tolightuserdata(L:State, idx:Int):cpp.Pointer<Void>;

	@:native("lua_tolightuserdatatagged")
	static function tolightuserdatatagged(L:State, idx:Int, tag:Int):cpp.Pointer<Void>;

	@:native("lua_touserdata")
	static function touserdata(L:State, idx:Int):cpp.Pointer<Void>;

	@:native("lua_touserdatatagged")
	static function touserdatatagged(L:State, idx:Int, tag:Int):cpp.Pointer<Void>;

	@:native("lua_userdatatag")
	static function userdatatag(L:State, idx:Int):Int;

	@:native("lua_lightuserdatatag")
	static function lightuserdatatag(L:State, idx:Int):Int;

	@:native("lua_tothread")
	static function tothread(L:State, idx:Int):State;

	@:native("lua_tobuffer")
	static function tobuffer(L:State, idx:Int, size:Ref<CSizeT>):cpp.Pointer<Void>;

	@:native("lua_topointer")
	static function topointer(L:State, idx:Int):cpp.Pointer<Void>;

	/*	 * Push functions (C -> stack)
	 */
	@:native("lua_pushnil")
	static function pushnil(L:State):Void;

	@:native("lua_pushnumber")
	static function pushnumber(L:State, n:LuaNumber):Void;

	@:native("lua_pushvector")
	static function pushvector(L:State, x:Float, y:Float, z:Float):Void;

	@:native("lua_pushstring")
	static function pushstring(L:State, s:CString):Void;

	@:native("lua_newuserdatatagged")
	static function newuserdatatagged(L:State, sz:CSizeT, tag:Int):cpp.Pointer<Void>;

	@:native("lua_newuserdata")
	static function newuserdata(L:State, sz:CSizeT):cpp.Pointer<Void>;

	/*
	 * Compile functions
	 */
	// FIXME the options type is complex and needs to be full externed
	@:native("luau_compile")
	static function _compile(source:CString, size:CSizeT, options:cpp.Pointer<CompileOptions>, bytecodeSize:cpp.Pointer<CSizeT>):cpp.ConstCharStar;

	/**
	 * Compile the source into bytecode.
	 * 
	 * In the case of compilation errors the error message will be placed into
	 * the return code. The error message will be available when luau_load is
	 * called to load the bytecode.
	 * 
	 * @param source the source text
	 * @param size the size of the source text
	 * @param options compiler options
	 * @return Code an opaque struct containing the compiled bytecode. This
	 * must not be modified or freed by the caller, and is only to be
	 * submitted to lua_load.
	 */
	static inline function compile(source:CString, size:CSizeT, ?options:CompileOptions):Code {
		var bytecodeSize:CSizeT = 0;
		var bytecode = _compile(source, size, cpp.Pointer.addressOf(options), cpp.Pointer.addressOf(bytecodeSize));
		var rv = new Code();
		rv.code = bytecode;
		rv.size = bytecodeSize;
		return rv;
	};

	/*
	 * `load` and `call` functions (load and run Luau bytecode)
	 */
	@:native("luau_load")
	static function _load(L:State, name:String, bytecode:Bytecode, bytecodeSize:CSizeT, mode:Int):Int;

	/**
	 * Load a chunk of compiled bytecode.
	 * @param L the Lua state
	 * @param name an identifier to include in error messages
	 * @param bytecode the compiled bytecode and its size
	 * @param env 0 for the current environment or a stack index pointing
	 * to a table to use as the environment
	 * @return Int 0 for success, and 1 for failure. Note, this is not a
	 * LuaStatus value. This is a Luau function not a Lua one.
	 */
	static inline function load(L:State, name:String, bytecode:Code, env:Int):Int {
		return _load(L, name, bytecode.code, bytecode.size, env);
	}

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
	 * Convert a value to a number.
	 *
	 * @param L The Lua state.
	 * @param idx The index of the value.
	 * @return The number.
	 */
	@:native('lua_tonumber')
	static function tonumber(L:State, idx:Int):Float;
}
