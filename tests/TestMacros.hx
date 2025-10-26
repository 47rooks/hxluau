package;

import Lua;
import utest.Assert;
import utest.Test;

class TestMacros extends Test {
	function testToNumber() {
		var L = Lua.newstate();
		Lua.pushstring(L, "42.5");
		var num = Lua.tonumber(L, -1);
		Assert.equals(42.5, num);
		Lua.close(L);
	}

	function testToInteger() {
		var L = Lua.newstate();
		Lua.pushstring(L, "123");
		var i = Lua.tointeger(L, -1);
		Assert.equals(123, i);
		Lua.close(L);
	}

	function testToUnsigned() {
		var L = Lua.newstate();
		Lua.pushstring(L, "4294967295");
		var u = Lua.tounsigned(L, -1);
		Assert.equals(4294967295, u);
		Lua.close(L);
	}

	function testPop() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 1);
		Lua.pushnumber(L, 2);
		Lua.pushnumber(L, 3);
		Assert.equals(3, Lua.gettop(L));
		Lua.pop(L, 2);
		Assert.equals(1, Lua.gettop(L));
		Lua.close(L);
	}

	function testNewTable() {
		var L = Lua.newstate();
		Lua.newtable(L);
		Assert.isTrue(Lua.istable(L, -1) == 1);
		Lua.close(L);
	}

	function testNewUserdata() {
		var L = Lua.newstate();
		var ptr = Lua.newuserdata(L, 16);
		Assert.notNull(ptr);
		Assert.isTrue(Lua.isuserdata(L, -1) == 1);
		Lua.close(L);
	}

	function testStrlen() {
		var L = Lua.newstate();
		Lua.pushstring(L, "hello world");
		var len = Lua.strlen(L, -1);
		Assert.equals(11, len);
		Lua.close(L);
	}

	function testIsNil() {
		var L = Lua.newstate();
		Lua.pushnil(L);
		Assert.isTrue(Lua.isnil(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsBoolean() {
		var L = Lua.newstate();
		Lua.pushboolean(L, 1);
		Assert.isTrue(Lua.isboolean(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsNumber() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 3.14);
		Assert.isTrue(Lua.isnumber(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsTable() {
		var L = Lua.newstate();
		Lua.newtable(L);
		Assert.isTrue(Lua.istable(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsString() {
		var L = Lua.newstate();
		Lua.pushstring(L, "str");
		Assert.isTrue(Lua.isstring(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsThread() {
		var L = Lua.newstate();
		Lua.pushthread(L);
		Assert.isTrue(Lua.isthread(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsUserdata() {
		var L = Lua.newstate();
		var ptr = Lua.newuserdata(L, 4);
		Assert.isTrue(Lua.isuserdata(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	// FIXME pointer types are wrong
	// function testIsLightUserdata() {
	// 	var L = Lua.newstate();
	// 	var n = 123;
	// 	var ptr = cpp.Pointer.addressOf(n);
	// 	Lua.pushlightuserdata(L, ptr);
	// 	Assert.isTrue(Lua.islightuserdata(L, -1) == 1);
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }

	function testIsVector() {
		var L = Lua.newstate();
		Lua.pushvector(L, 1, 2, 3);
		Assert.isTrue(Lua.isvector(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	// FIXME - pushbuffer does not exit - how do we test this ?
	// function testIsBuffer() {
	// 	var L = Lua.newstate();
	// 	Lua.pushbuffer(L, 8);
	// 	Assert.isTrue(Lua.isbuffer(L, -1) == 1);
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }

	function testIsNone() {
		var L = Lua.newstate();
		Lua.pushnil(L);
		Assert.isTrue(Lua.isnone(L, -1) == 0); // -1 is valid, so not none
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsNoneOrNil() {
		var L = Lua.newstate();
		Lua.pushnil(L);
		Assert.isTrue(Lua.isnoneornil(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	// FIXME generated code does not compile
	// function testPushLiteral() {
	// 	var L = Lua.newstate();
	// 	Lua.pushliteral(L, "lit");
	// 	Assert.equals("lit", Lua.tostring(L, -1));
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }

	function testSetFieldGetField() {
		var L = Lua.newstate();
		Lua.newtable(L);
		Lua.pushstring(L, "val");
		Lua.setfield(L, -2, "key");
		Lua.getfield(L, -1, "key");
		Assert.equals("val", Lua.tostring(L, -1));
		Lua.pop(L, 2);
		Lua.close(L);
	}

	// FIXME pointer types are wrong
	// function testTolString() {
	// 	var L = Lua.newstate();
	// 	Lua.pushstring(L, "foobar");
	// 	var n = 0;
	// 	var lenRef = cpp.Pointer.addressOf(n);
	// 	var cstr = Lua.tolstring(L, -1, lenRef);
	// 	Assert.equals("foobar", cstr);
	// 	Assert.equals(6, lenRef.get_value());
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }
	// FIXME needs more work to handle mixed types in the list of
	// arguments to pushfstring
	// function testPushFString() {
	// 	var L = Lua.newstate();
	// 	Lua.pushfstring(L, "Hello %s %d", "world", 123);
	// 	Assert.equals("Hello world 123", Lua.tostring(L, -1));
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }
	// FIXME these two need funcion refs sorted out
	// function testPushCFunction() {
	// 	var L = Lua.newstate();
	// 	var called = false;
	// 	var cfunc:Lua.LuaCFunction = function(L) {
	// 		called = true;
	// 		return 0;
	// 	};
	// 	Lua.pushcfunction(L, cfunc);
	// 	Assert.isTrue(Lua.iscfunction(L, -1) == 1);
	// 	Lua.pcall(L, 0, 0, 0);
	// 	Assert.isTrue(called);
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }
	// function testPushCClosure() {
	// 	var L = Lua.newstate();
	// 	var called = false;
	// 	var cfunc:Lua.LuaCFunction = function(L) {
	// 		called = true;
	// 		return 0;
	// 	};
	// 	Lua.pushcclosure(L, cfunc, 0);
	// 	Assert.isTrue(Lua.iscfunction(L, -1) == 1);
	// 	Lua.pcall(L, 0, 0, 0);
	// 	Assert.isTrue(called);
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }

	function testPushLightUserdata() {
		var L = Lua.newstate();
		var n = 123;
		var ptr = cpp.Pointer.addressOf(n);
		Lua.pushlightuserdata(L, cast ptr);
		Assert.isTrue(Lua.islightuserdata(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}
}
