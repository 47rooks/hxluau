package;

import Lua;
import utest.Assert;
import utest.Test;

class TestPushFunctions extends Test {
	function testPushNil() {
		var L = Lua.newstate();
		Lua.pushnil(L);
		Assert.equals(LuaType.NIL, Lua.type(L, -1), "pushnil should push nil");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushNumber() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 3.14);
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1), "pushnumber should push a number");
		Assert.equals(3.14, Lua.tonumber(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushInteger() {
		var L = Lua.newstate();
		Lua.pushinteger(L, 42);
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1), "pushinteger should push a number");
		Assert.equals(42, Lua.tonumber(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushUnsigned() {
		var L = Lua.newstate();
		Lua.pushunsigned(L, 123);
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1), "pushunsigned should push a number");
		Assert.equals(123, Lua.tonumber(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushVector() {
		var L = Lua.newstate();
		#if (LuaDefines.VECTOR_SIZE == 4)
		Lua.pushvector(L, 1, 2, 3, 4);
		var vec = Lua.tovector(L, -1);
		Assert.equals(4, vec.length);
		Assert.equals(1, vec[0]);
		Assert.equals(2, vec[1]);
		Assert.equals(3, vec[2]);
		Assert.equals(4, vec[3]);
		#else
		Lua.pushvector(L, 1, 2, 3);
		var vec = Lua.tovector(L, -1);
		Assert.equals(3, vec.length);
		Assert.equals(1, vec[0]);
		Assert.equals(2, vec[1]);
		Assert.equals(3, vec[2]);
		#end
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushLString() {
		var L = Lua.newstate();
		Lua.pushlstring(L, "abc", 3);
		var str:String = Lua.tostring(L, -1);
		Assert.equals("abc", str);
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushString() {
		var L = Lua.newstate();
		Lua.pushstring(L, "hello");
		var str:String = Lua.tostring(L, -1);
		Assert.equals("hello", str);
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME figure this out
	// pushvfstring, pushfstringL, pushcclosurek: not easily testable in Haxe without C varargs or C function pointers

	function testPushBoolean() {
		var L = Lua.newstate();
		Lua.pushboolean(L, 1);
		Assert.equals(LuaType.BOOLEAN, Lua.type(L, -1));
		Assert.equals(1, Lua.toboolean(L, -1));
		Lua.settop(L, 0);
		Lua.pushboolean(L, 0);
		Assert.equals(0, Lua.toboolean(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushThread() {
		var L = Lua.newstate();
		Lua.pushthread(L);
		Assert.equals(LuaType.THREAD, Lua.type(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME get rid of pointers
	// FIXME type of pointer is also a problem
	// function testPushLightUserdataTagged() {
	// 	var L = Lua.newstate();
	// 	var num = 12345;
	// 	var ptr = cpp.Pointer.addressOf(num);
	// 	Lua.pushlightuserdatatagged(L, ptr, 99);
	// 	Assert.equals(LuaType.LIGHTUSERDATA, Lua.type(L, -1));
	// 	Assert.equals(99, Lua.lightuserdatatag(L, -1));
	// 	Lua.settop(L, 0);
	// 	Lua.close(L);
	// }

	function testNewUserdataTagged() {
		var L = Lua.newstate();
		var tag = 77;
		var ptr = Lua.newuserdatatagged(L, 8, tag);
		Assert.notNull(ptr);
		Assert.equals(tag, Lua.userdatatag(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testNewUserdataTaggedWithMetatable() {
		var L = Lua.newstate();
		var tag = 88;
		var ptr = Lua.newuserdatataggedwithmetatable(L, 8, tag);
		Assert.notNull(ptr);
		Assert.equals(tag, Lua.userdatatag(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME looks weak
	function testNewUserdataDtor() {
		var L = Lua.newstate();
		var ptr = Lua.newuserdatadtor(L, 8, null);
		Assert.notNull(ptr);
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME looks weak
	function testNewBuffer() {
		var L = Lua.newstate();
		var ptr = Lua.newbuffer(L, 16);
		Assert.notNull(ptr);
		Lua.settop(L, 0);
		Lua.close(L);
	}
}
