package;

import Luau.LuaStatus;
import cpp.SizeT;

class Main {
	public static function main() {
		var L = Luau.newstate();
		var source = "a = 7 + 11 - 12";
		var byteCodeSize:SizeT = 0;

		var byteCode = Luau.luau_compile(source, source.length, null, cpp.Pointer.addressOf(byteCodeSize).ptr);
		trace(byteCodeSize);
		var r = Luau.luau_load(L, "code", byteCode, byteCodeSize, 0);
		if (r != LuaStatus.LUA_OK) {
			trace('Error loading chunk: ${Luau.tostring(L, -1)}');
			Luau.pop(L, 1); // remove error message
			Sys.exit(1);
		}
		Luau.call(L, 0, 1); // call the loaded chunk
		Luau.getglobal(L, "a");
		if (Luau.isnumber(L, -1) == 1) {
			trace('Result: ${Luau.tonumber(L, -1)}');
		} else {
			trace('Error: "a"" is not a number.');
		}
	}
}
