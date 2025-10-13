package;

import Lua.LuaStatus;
import cpp.SizeT;

class Main {
	public static function main() {
		var L = Lua.newstate();
		var source = "a = 7 + 11 - 12";
		var byteCodeSize:SizeT = 0;

		var byteCode = Lua.luau_compile(source, source.length, null, cpp.Pointer.addressOf(byteCodeSize).ptr);
		trace(byteCodeSize);
		var r = Lua.luau_load(L, "code", byteCode, byteCodeSize, 0);
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
