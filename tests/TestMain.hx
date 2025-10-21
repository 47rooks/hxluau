package;

import Lua.CSizeT;
import Lua.CompileOptions;
import Lua.LuaStatus;
import utest.Runner;
import utest.ui.Report;

class TestMain {
	public static function main() {
		trace('running');
		utest.UTest.run([
			new TestCompile(),
			new TestState(),
			new TestBasicStackOps(),
			new TestAccessFunctions()
		]);
	}
}
