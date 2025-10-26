package;

import Lua;
import utest.Assert;
import utest.Test;

class TestDebug extends Test {
	function testStackDepth() {
		var L = Lua.newstate();
		var depth = Lua.stackdepth(L);
		Assert.isTrue(depth >= 0);
		Lua.close(L);
	}

	function testGetArgument() {
		var L = Lua.newstate();
		// No stack frames, should return 0 or error
		var arg = Lua.getargument(L, 0, 0);
		Assert.isTrue(arg == 0);
		Lua.close(L);
	}

	function testGetLocalSetLocal() {
		var L = Lua.newstate();
		// No stack frames, should return null
		var localName = Lua.getlocal(L, 0, 0);
		Assert.isTrue(localName == null || localName == "");
		var setName = Lua.setlocal(L, 0, 0);
		Assert.isTrue(setName == null || setName == "");
		Lua.close(L);
	}

	// FIXME function typedef needs fixing then this can work
	// function testGetUpvalueSetUpvalue() {
	// 	var L = Lua.newstate();
	// 	Lua.pushcfunction(L, function(L) {
	// 		return 0;
	// 	});
	// 	var name = Lua.getupvalue(L, -1, 1);
	// 	Assert.isTrue(name == null || name == "");
	// 	var setName = Lua.setupvalue(L, -1, 1);
	// 	Assert.isTrue(setName == null || setName == "");
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }

	function testSingleStep() {
		var L = Lua.newstate();
		Lua.singlestep(L, 1);
		Lua.singlestep(L, 0);
		Lua.close(L);
	}

	// FIXME need function typedef fix for this to work
	// function testBreakpoint() {
	// 	var L = Lua.newstate();
	// 	Lua.pushcfunction(L, function(L) {
	// 		return 0;
	// 	});
	// 	var result = Lua.breakpoint(L, -1, 1, 1);
	// 	Assert.isTrue(result == 0 || result == 1);
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }

	function testDebugTrace() {
		var L = Lua.newstate();
		var trace = Lua.debugtrace(L);
		Assert.isTrue(trace != null);
		Lua.close(L);
	}

	// FIXME add test for coverage once it is implemented
	// FIXME also add debug hook tests
}
