package;

import Lua.CSizeT;
import Lua.CompileOptions;
import Lua.LuaStatus;

class Main {
	public static function main() {
		var L = Lua.newstate();
		// var source = "a = 7 + 11 - 12 * 12";
		// var source = "a = 7 + 11 - 12 * 12; a = a + 1;";
		var source = "a = 7 + 11";

		// Cannot pass null so use an empty struct.
		// Cannot instantiate {} directly as call site, so use a local variable.
		var options:CompileOptions = {};

		var byteCode = Lua.compile(source, source.length, options);
		trace('bytecode length: ${byteCode.size}');
		var r = Lua.load(L, "code", byteCode, 0);
		if (r != LuaStatus.OK) {
			trace('Error loading chunk: ${Lua.tostring(L, -1)}');
			Lua.pop(L, 1); // remove error message
			Sys.exit(1);
		}
		Lua.call(L, 0, 1); // call the loaded chunk
		Lua.getglobal(L, "a");
		if (Lua.isnumber(L, -1) == 1) {
			trace('Result: ${Lua.tonumber(L, -1)}');
		} else {
			trace('Error: "a"" is not a number.');
		}
		trace('Lua.MULTRET: ${Lua.MULTRET}');
		trace('LuaStatus.LUA_YIELD: ${LuaStatus.YIELD}');
	}
}
