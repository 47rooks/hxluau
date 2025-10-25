package;

import Lua.LuaType;
import Lua.State;
import Lua;
import LuaCode.CompileOptions;
import utest.Assert;
import utest.Test;

class TestLoadAndCall extends Test {
	var L:State;

	public function setup() {
		L = Lua.newstate();
	}

	public function teardown() {
		Lua.close(L);
	}

	public function testLoadAndCallSimpleChunk() {
		var source = "return 123";
		var options:CompileOptions = {};
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status); // 0 for success
		Lua.call(L, 0, 1);
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(123.0, Lua.tonumber(L, -1));
		Lua.pop(L, 1);
	}

	public function testLoadAndCallWithArgs() {
		var source = "local a, b = ...; return a + b";
		var options:CompileOptions = {};
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status);
		Lua.pushnumber(L, 10);
		Lua.pushnumber(L, 32);
		Lua.call(L, 2, 1);
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(42.0, Lua.tonumber(L, -1));
		Lua.pop(L, 1);
	}

	public function testLoadSyntaxError() {
		var source = "return =";
		var options:CompileOptions = {};
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(1, status); // 1 for failure
	}

	public function testCallNoReturn() {
		var source = "local x = 5";
		var options:CompileOptions = {};
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status);
		Lua.call(L, 0, 0); // no return values
		Assert.equals(0, Lua.gettop(L));
	}

	public function testPcallSuccess() {
		var source = "return 99";
		var options:CompileOptions = {};
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status);
		var pcallStatus = Lua.pcall(L, 0, 1, 0);
		Assert.equals(0, pcallStatus); // LUA_OK
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(99.0, Lua.tonumber(L, -1));
		Lua.pop(L, 1);
	}

	public function testPcallError() {
		var source = "error('fail')";
		var options:CompileOptions = {};
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status);
		var pcallStatus = Lua.pcall(L, 0, 1, 0);
		Assert.notEquals(0, pcallStatus); // Should not be LUA_OK
		Lua.pop(L, 1);
	}

	// FIXME: this needs a lot of work
	// public function testCpcall() {
	// 	var called = false;
	// 	var cfunc:LuaCFunction = function(L:State):Int {
	// 		called = true;
	// 		Lua.pushnumber(L, 1234);
	// 		return 1;
	// 	};
	// 	var status = Lua.cpcall(L, cfunc, null);
	// 	Assert.equals(0, status); // LUA_OK
	// 	Assert.isTrue(called);
	// 	Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
	// 	Assert.equals(1234.0, Lua.tonumber(L, -1));
	// 	Lua.pop(L, 1);
	// }
}
