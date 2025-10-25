package;

import Lua.CSizeT;
import Lua.LuaStatus;
import LuaCode.CompileOptions;
import TestBasicStackOps;
import TestCompile;
import TestCoroutines;
import TestGC;
import TestGetFunctions;
import TestLoadAndCall;
import TestMemoryStats;
import TestMetatablesAlt;
import TestMiscFunctions;
import TestPushFunctions;
import TestRef;
import TestState;
import utest.Runner;
import utest.ui.Report;

class TestMain {
	public static function main() {
		trace('running');
		utest.UTest.run([
			new TestCompile(),
			new TestState(),
			new TestBasicStackOps(),
			new TestAccessFunctions(),
			new TestPushFunctions(),
			new TestGetFunctions(),
			new TestLoadAndCall(),
			new TestCoroutines(),
			new TestGC(),
			new TestMemoryStats(),
			new TestMiscFunctions(),
			new TestMetatablesAlt(),
			new TestRef()
		]);
	}
}
