package;

import Lua.LuaType;
import Lua.State;
import Lua;
import haxe.ds.Vector;
import utest.Assert;
import utest.Test;

// FIXME go through and clean up
//       verify all tests are useful, add missing tests
class TestGetFunctions extends Test {
	var L:State;

	public function setup() {
		L = Lua.newstate();
	}

	public function teardown() {
		Lua.close(L);
	}

	public function testGetGlobal() {
		Lua.pushnumber(L, 42);
		Lua.setglobal(L, "myglobal");
		var result = Lua.getglobal(L, "myglobal");
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(42.0, Lua.tonumber(L, -1));
		Lua.pop(L, 1);
	}

	public function testGetField() {
		Lua.createtable(L, 0, 1);
		Lua.pushnumber(L, 123);
		Lua.setfield(L, -2, "foo");
		Lua.getfield(L, -1, "foo");
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(123.0, Lua.tonumber(L, -1));
		Lua.pop(L, 2);
	}

	public function testRawGetField() {
		Lua.createtable(L, 0, 1);
		Lua.pushnumber(L, 99);
		Lua.setfield(L, -2, "bar");
		Lua.rawgetfield(L, -1, "bar");
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(99.0, Lua.tonumber(L, -1));
		Lua.pop(L, 2);
	}

	public function testRawGet() {
		Lua.createtable(L, 1, 0);
		Lua.pushnumber(L, 7);
		Lua.rawseti(L, -2, 1);
		Lua.rawget(L, -1);
		Assert.equals(LuaType.TABLE, Lua.type(L, -1));
		Lua.pop(L, 1);
	}

	public function testRawGetI() {
		Lua.createtable(L, 1, 0);
		Lua.pushnumber(L, 55);
		Lua.rawseti(L, -2, 1);
		Lua.rawgeti(L, -1, 1);
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(55.0, Lua.tonumber(L, -1));
		Lua.pop(L, 2);
	}

	public function testCreateTable() {
		Lua.createtable(L, 2, 2);
		Assert.equals(LuaType.TABLE, Lua.type(L, -1));
		Lua.pop(L, 1);
	}

	public function testGetMetatable() {
		Lua.createtable(L, 0, 0);
		Lua.createtable(L, 0, 0);
		Lua.setmetatable(L, -2);
		var hasMeta = Lua.getmetatable(L, -1);
		Assert.equals(1, hasMeta);
		Assert.equals(LuaType.TABLE, Lua.type(L, -1));
		Lua.pop(L, 2);
	}

	public function testGetFenv() {
		Lua.createtable(L, 0, 0);
		Lua.getfenv(L, -1);
		Assert.equals(LuaType.TABLE, Lua.type(L, -1));
		Lua.pop(L, 2);
	}

	public function testGetReadonlySetReadonly() {
		Lua.createtable(L, 0, 0);
		Lua.setreadonly(L, -1, 1);
		var readonly = Lua.getreadonly(L, -1);
		Assert.equals(1, readonly);
		Lua.setreadonly(L, -1, 0);
		readonly = Lua.getreadonly(L, -1);
		Assert.equals(0, readonly);
		Lua.pop(L, 1);
	}

	public function testGetTable() {
		Lua.createtable(L, 0, 1);
		Lua.pushnumber(L, 77);
		Lua.setfield(L, -2, "baz");
		Lua.pushstring(L, "baz");
		Lua.gettable(L, -2);
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(77.0, Lua.tonumber(L, -1));
		Lua.pop(L, 2);
	}

	public function testSetSafeEnvGetSafeEnv() {
		Lua.createtable(L, 0, 0);
		Lua.setsafeenv(L, -1, 1);
		// No direct get function, but can check readonly
		var readonly = Lua.getreadonly(L, -1);
		Assert.equals(1, readonly);
		Lua.setsafeenv(L, -1, 0);
		readonly = Lua.getreadonly(L, -1);
		Assert.equals(0, readonly);
		Lua.pop(L, 1);
	}
}
