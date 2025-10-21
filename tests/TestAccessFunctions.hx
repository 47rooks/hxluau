package;

import Lua;
import utest.Assert;
import utest.Test;

// FIXME remove of cpp references.
// There are output pointers which we need to figure out generically.
class TestAccessFunctions extends Test {
	function testIsNumber() {
		var L = Lua.newstate();
		Lua.getglobal(L, "_G");
		Assert.equals(0, Lua.isnumber(L, -1), "_G is a number");
		Lua.settop(L, 0);

		// Push a number
		Lua.pushnumber(L, 12);
		Assert.equals(1, Lua.isnumber(L, -1), "_G is not a number");

		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testIsString() {
		var L = Lua.newstate();
		Lua.getglobal(L, "_G");
		Assert.equals(0, Lua.isstring(L, -1), "_G is not a string");
		Lua.settop(L, 0);

		// Push a string
		Lua.pushstring(L, "hello");
		Assert.equals(1, Lua.isstring(L, -1), "Should detect pushed string");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testIsCFunction() {
		var L = Lua.newstate();
		Lua.getglobal(L, "print");
		Assert.equals(1, Lua.iscfunction(L, -1), "print should be a C function");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testIsLFunction() {
		var L = Lua.newstate();
		Lua.getglobal(L, "_G");
		Assert.equals(0, Lua.isLfunction(L, -1), "_G is not a Lua function");
		Lua.settop(L, 0);

		// Push a Lua function
		// FIXME convert to compile/load and then check
		// Lua.dostring(L, "return function() return 42 end"); // pushes a function
		Assert.equals(1, Lua.isLfunction(L, -1), "Should detect pushed Lua function");

		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testIsUserdata() {
		var L = Lua.newstate();
		Lua.getglobal(L, "_G");
		Assert.equals(0, Lua.isuserdata(L, -1), "_G is not userdata");
		Lua.settop(L, 0);

		// Push userdata (simulate by creating a new userdata)
		Lua.newuserdata(L, 8); // push 8 bytes of userdata
		Assert.equals(1, Lua.isuserdata(L, -1), "Should detect pushed userdata");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTypeAndTypename() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 12);
		Lua.pushstring(L, "hello");

		var tp = Lua.type(L, -2);
		var name:String = Lua.typename(L, tp);
		Assert.equals("number", name, 'type should be a number, but is ${name}');

		var tp = Lua.type(L, -1);
		var name:String = Lua.typename(L, tp);
		Assert.equals("string", name, 'type should be a string, but is ${name}');

		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testEqualAndRawEqual() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 5);
		Lua.pushnumber(L, 5);
		Assert.equals(1, Lua.equal(L, -1, -2), "equal should return 1 for equal numbers");
		Assert.equals(1, Lua.rawequal(L, -1, -2), "rawequal should return 1 for equal numbers");
		Lua.settop(L, 0);
		Lua.pushnumber(L, 5);
		Lua.pushnumber(L, 6);
		Assert.equals(0, Lua.equal(L, -1, -2), "equal should return 0 for different numbers");
		Assert.equals(0, Lua.rawequal(L, -1, -2), "rawequal should return 0 for different numbers");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testLessThan() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 3);
		Lua.pushnumber(L, 5);
		Assert.equals(1, Lua.lessthan(L, -2, -1), "lessthan should return 1 for 3 < 5");
		Assert.equals(0, Lua.lessthan(L, -1, -2), "lessthan should return 0 for 5 < 3");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTonumberx() {
		var L = Lua.newstate();
		Lua.pushstring(L, "123.5");
		var isnum = 0;
		var num = Lua.tonumberx(L, -1, cpp.Pointer.addressOf(isnum).ptr);
		Assert.equals(1, isnum, "tonumberx should set isnum to 1 for valid number string");
		Assert.equals(123.5, num, "tonumberx should convert string to number");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTointegerx() {
		var L = Lua.newstate();
		Lua.pushstring(L, "42");
		var isnum = 0;
		var num = Lua.tointegerx(L, -1, cpp.Pointer.addressOf(isnum).ptr);
		Assert.equals(1, isnum, "tointegerx should set isnum to 1 for valid integer string");
		Assert.equals(42, num, "tointegerx should convert string to integer");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTounsignedx() {
		var L = Lua.newstate();
		Lua.pushstring(L, "123");
		var isnum = 0;
		var num = Lua.tounsignedx(L, -1, cpp.Pointer.addressOf(isnum).ptr);
		Assert.equals(1, isnum, "tounsignedx should set isnum to 1 for valid unsigned string");
		Assert.equals(123, num, "tounsignedx should convert string to unsigned");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTounsigned() {
		var L = Lua.newstate();
		Lua.pushstring(L, "4294967295");
		var num = Lua.tounsigned(L, -1);
		Assert.equals(0xFFFFFFFFu32, num, "tounsigned should convert string to unsigned");
		trace('num=${num}');
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTovector() {
		var L = Lua.newstate();
		Lua.pushvector(L, 1.5, 2.5, 3.5);
		var vec = Lua.tovector(L, -1);
		trace('LUA_VECTOR_SIZE=${LuaDefines.VECTOR_SIZE}');
		trace('vec=${vec}');
		Assert.notNull(vec, "tovector should return a pointer (may be null if not supported)");
		Assert.equals(vec[0], 1.5, "vec[0] should be 1.5");
		Assert.equals(vec[1], 2.5, "vec[0] should be 2.5");
		Assert.equals(vec[2], 3.5, "vec[0] should be 3.5");

		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTovectorErr() {
		var L = Lua.newstate();
		Lua.pushstring(L, "hello");
		var vec = Lua.tovector(L, -1);
		trace('vec=${vec}');

		Assert.isNull(vec, "tovector should return a null pointer");

		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testToboolean() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 0);
		Assert.equals(0, Lua.toboolean(L, -1), "toboolean should return 0 for 0");
		Lua.settop(L, 0);
		Lua.pushnumber(L, 1);
		Assert.equals(1, Lua.toboolean(L, -1), "toboolean should return 1 for nonzero");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTolstring() {
		var L = Lua.newstate();
		Lua.pushstring(L, "abc");
		var len:CSizeT = 0;
		var str:String = Lua.tolstring(L, -1, cpp.Pointer.addressOf(len).ptr);
		Assert.equals(3, len, "tolstring should set length to 3 for 'abc'");
		Assert.equals("abc", str, "tolstring should return 'abc'");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTostringatom() {
		var L = Lua.newstate();
		Lua.pushstring(L, "foo");
		var atom = 0;
		var str:String = Lua.tostringatom(L, -1, cpp.Pointer.addressOf(atom).ptr);
		Assert.equals("foo", str, "tostringatom should return 'foo'");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTolstringatom() {
		var L = Lua.newstate();
		Lua.pushstring(L, "bar");
		var len:CSizeT = 0;
		var atom = 0;
		var str:String = Lua.tolstringatom(L, -1, cpp.Pointer.addressOf(len).ptr, cpp.Pointer.addressOf(atom).ptr);
		Assert.equals(3, len, "tolstringatom should set length to 3 for 'bar'");
		Assert.equals("bar", str, "tolstringatom should return 'bar'");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testNamecallatom() {
		var L = Lua.newstate();
		var atom = 0;
		var str = Lua.namecallatom(L, cpp.Pointer.addressOf(atom).ptr);
		Assert.isOfType(str, String, "namecallatom should return a string (may be empty)");
		Lua.close(L);
	}

	function testObjLen() {
		var L = Lua.newstate();
		Lua.pushstring(L, "hello");
		var len = Lua.objlen(L, -1);
		Assert.equals(5, len, "objlen should return 5 for 'hello'");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME add this test when we resolve the pointer issues
	//
	// function testTocfunction() {
	// 	var L = Lua.newstate();
	// 	Lua.getglobal(L, "print");
	// 	var fn = Lua.tocfunction(L, -1);
	// 	Assert.notNull(fn, "tocfunction should return a function pointer for C function");
	// 	Lua.settop(L, 0);
	// 	Lua.close(L);
	// }
	// FIXME to test positive case need pushlightuserdata
	function testTolightuserdata() {
		var L = Lua.newstate();
		Lua.pushnil(L);
		var ptr = Lua.tolightuserdata(L, -1);
		Assert.isNull(ptr, "tolightuserdata should return null for nil");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME to test positive case need pushuserdatatag

	function testTolightuserdatatagged() {
		var L = Lua.newstate();
		Lua.pushnil(L);
		var ptr = Lua.tolightuserdatatagged(L, -1, 12);
		Assert.isNull(ptr, "tolightuserdatatagged should return null for nil");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTouserdata() {
		var L = Lua.newstate();
		Lua.newuserdata(L, 4);
		var ptr = Lua.touserdata(L, -1);
		Assert.notNull(ptr, "touserdata should return pointer for userdata");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTouserdatatagged() {
		var L = Lua.newstate();
		Lua.newuserdatatagged(L, 4, 0);
		var ptr = Lua.touserdatatagged(L, -1, 15);
		Assert.notNull(ptr, "touserdatatagged should return pointer for tagged userdata");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testUserdataTag() {
		var L = Lua.newstate();
		var tag = 123;
		Lua.newuserdatatagged(L, 8, tag);
		var stackTag = Lua.userdatatag(L, -1);
		Assert.equals(tag, stackTag, "userdatatag should return the tag used to create the userdata");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME add this test when pushlightuserdatatag is added
	// function testLightUserdataTag() {
	// 	var L = Lua.newstate();
	// 	// Push a light userdata with a tag (simulate with a pointer, tag may be implementation-specific)
	// 	var ptr = cpp.Pointer.addressOf(12345); // Simulate a pointer value
	// 	Lua.pushlightuserdata(L, ptr);
	// 	var tag = Lua.lightuserdatatag(L, -1);
	// 	// The expected tag value depends on your implementation; typically 0 for untagged
	// 	Assert.notNull(tag, "lightuserdatatag should return a tag (may be 0 for untagged)");
	// 	Lua.settop(L, 0);
	// 	Lua.close(L);
	// }

	function testTothread() {
		var L = Lua.newstate();
		var thread = Lua.newthread(L);
		var result = Lua.tothread(thread, -1);
		Assert.notNull(result, "tothread should return a thread pointer");
		Lua.close(L);
	}

	// FIXME add this test when we resolve the pointer issues
	//       this should be done by calling a generic wrapper and
	//       having it get the pointers in the cpp impl.
	// function testTobuffer() {
	// 	var L = Lua.newstate();
	// 	var s = "buffer";
	// 	Lua.pushstring(L, s);
	// 	var buf = Lua.tobuffer(L, -1, s.length);
	// 	Assert.notNull(buf, "tobuffer should return a pointer (may be null if not supported)");
	// 	Lua.settop(L, 0);
	// 	Lua.close(L);
	// }

	function testTopointer() {
		var L = Lua.newstate();
		Lua.pushstring(L, "ptr");
		var ptr = Lua.topointer(L, -1);
		Assert.notNull(ptr, "topointer should return a pointer for string");
		Lua.settop(L, 0);
		Lua.close(L);
	}
}
