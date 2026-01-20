package;

import Lua.CSizeT;
import Lua.LuaStatus;
import Lua.NativeState;
import Lua.State;
import LuaCode.CompileOptions;
// import Require.NavigateResult;
import Require;
import Types.CString;
import VFSNavigator.NavigationStatus;
import cpp.Pointer;
import cpp.RawPointer;
import haxe.io.BytesBuffer;
import sys.FileSystem;
import sys.io.File;

// typedef BoolCheck = () -> Bool;
// typedef Coverage = (lua_State:State, int:Int) -> Void;
// class Requirer {
// 	public var copts:CompileOptions;
// 	public var coverageActive:BoolCheck;
// 	public var codegenEnabled:BoolCheck;
// 	public var coverageTrack:Coverage;
// 	public var vfs:VFSNavigator;
// 	public function new(copts:CompileOptions, coverageActive:BoolCheck, codegenEnabled:BoolCheck, coverageTrack:Coverage) {
// 		this.copts = copts;
// 		this.coverageActive = coverageActive;
// 		this.codegenEnabled = codegenEnabled;
// 		this.coverageTrack = coverageTrack;
// 		this.vfs = new VFSNavigator();
// 	}
// }
class Requirer {
	public static function convert(status:NavigationStatus):NavigateResult {
		return switch (status) {
			case Success: NavigateResult.SUCCESS;
			case Ambiguous: NavigateResult.AMBIGUOUS;
			case NotFound: NavigateResult.NOT_FOUND;
		}
	}

	public static function isRequireAllowed(L:State, ctx:RequireCtx, requirerChunkname:String):Bool {
		// public static function isRequireAllowed(L:State, requirerChunkname:String):Bool {
		// public static function isRequireAllowed(L:State):Bool {
		trace("isRequireAllowed got called");
		trace('requirer chunkname=${requirerChunkname}');
		trace('data->number_of_calls=${ctx.data.number_of_calls}');
		var chunkname:String = requirerChunkname;
		// FIXME define chunkname convention.
		//       Will matter more in flixel/openfl/lime asset context.
		// return chunkname == "=stdin" || (chunkname.length > 0 && chunkname.charAt(0) == '@');
		return true;
	}

	public static function reset(L:State, ctx:RequireCtx, requirerChunkname:String):NavigateResult {
		trace('reset got called from chunk: ${requirerChunkname}');

		if (requirerChunkname == "=stdin") {
			return convert(ctx.vfs.resetToStdIn());
		} else if (requirerChunkname.length > 0 && requirerChunkname.charAt(0) == '@') {
			return convert(ctx.vfs.resetToPath(requirerChunkname.substr(1)));
		}
		// This is just a test example where we assume that chunknames
		// are the file names of the loaded Luau code.
		var rv = convert(ctx.vfs.resetToPath(requirerChunkname));
		trace('reset returning ${rv}');
		return rv;
	}

	// public static function jumpToAlias(L:State, ctx:RawPointer<cpp.Void>, path:CString):NavigateResult {
	// 	var req:RequireCtx = cast cpp.Pointer.fromRaw(ctx).value;
	// 	var pathStr:String = path;
	// 	// TODO: check if absolute
	// 	return convert(req.vfs.resetToPath(pathStr));
	// }
	public static function toParent(L:State, ctx:RequireCtx):NavigateResult {
		trace('toParent got called');
		var rv = convert(ctx.vfs.toParent());
		trace('toParent returning ${rv}');
		return rv;
	}

	public static function toChild(L:State, ctx:RequireCtx, name:String):NavigateResult {
		trace('toChild called with name=${name}');
		var rv = convert(ctx.vfs.toChild(name));
		trace('toChild returning ${rv}');
		return rv;
	}

	public static function isModulePresent(L:State, ctx:RequireCtx):Bool {
		var path = ctx.vfs.getFilePath();
		return FileSystem.exists(path) && !FileSystem.isDirectory(path);
	}

	public static function getChunkname(L:State, ctx:RequireCtx):String {
		return "@" + ctx.vfs.getFilePath();
	}

	public static function getLoadname(L:State, ctx:RequireCtx):String {
		return ctx.vfs.getAbsoluteFilePath();
	}

	public static function getCacheKey(L:State, ctx:RequireCtx):String {
		trace('getCacheKey called');
		return ctx.vfs.getAbsoluteFilePath();
	}

	// public static function isConfigPresent(L:State, ctx:RawPointer<cpp.Void>):Bool {
	// 	var req:RequireCtx = cast cpp.Pointer.fromRaw(ctx).value;
	// 	var path = req.vfs.getLuaurcPath();
	// 	return FileSystem.exists(path) && !FileSystem.isDirectory(path);
	// }
	// public static function getConfig(L:State, ctx:RawPointer<cpp.Void>, buffer:RawPointer<cpp.Char>, bufferSize:CSizeT,
	// 		sizeOut:RawPointer<CSizeT>):WriteResult {
	// 	var req:RequireCtx = cast cpp.Pointer.fromRaw(ctx).value;
	// 	var path = req.vfs.getLuaurcPath();
	// 	var content = FileSystem.exists(path) ? File.getContent(path) : null;
	// 	return write(content, buffer, bufferSize, sizeOut);
	// }
	public static function load(L:State, ctx:RequireCtx, path:String, chunkname:String, loadname:String):Int {
		// Read file loadname
		trace('load: ${path}, ${loadname}');
		var content = sys.io.File.getContent(loadname);
		trace('load got\n${content}');
		// Compile the code
		var options = CompileOptions.create();
		options.debugLevel = 2;

		var code = LuaCode.compile(content, content.length, options);
		trace('code size=${code.size}');

		// Load the code
		var status = Lua.load(L, chunkname, code, 0);
		if (status != 0) {
			trace('Error loading chunk: ${Lua.tostring(L, -1)}');
		}

		// Execute the module
		var pcallStatus = Lua.pcall(L, 0, 1, 0);
		if (pcallStatus != 0) {
			trace('Error calling chunk: ${Lua.tostring(L, -1)}');
		}

		return LuaStatus.OK;
	}
	/*
		Design 1:
			The RequiteCtx has two parts. One is the state information that the
			Requirer needs for normal operation. The second is the various functions
			that the Luau Require modules needs in the config_init. These functions
			though are Haxe functions and cannot be passed directly to cpp. Instead
			The requireConfigInit will populate the Configuration object with
			jump or trampoline functions. These will be pure C functions so they
			will not have upvalues or context objects. Their job is to extract the
			correct Haxe function from the RequireCtx and call it with the parameters required.

			In order to do this the requireConfigInit function will become an
			extern and will mostly be written as cppNamespaceCode to create all
			the trampoline functions - one for each Configuration function.
			
			The RequireCtx object will be passed to the luaopen_require function.
			It will pass via wrapper which will root it and store the pointer in
			the REGISTRY as a userdata to ensure proper cleanup. Its destructor will
			remove the root.

		Design 2:
			Design has a more complex RequireCtx creation where each of the
			required Configuration callbacks fields is a property. The setter then
			create a callback function as a closure over the function object as
			is done in pushcfunction(). It then stores these in a named table
			in the Luau lua_State object.

			The configInit function is again an extern which creates jump functions
			which retrieve the context table from the State and then extract the
			correct field, marshal the parameters and make the call.

			This approach is more complex to implement and incurs an additional
			function call for each of the configured functions.
	 */
}
// @:cppNamespaceCode('
// #include <iostream>
// #include <lua.h>
// #include <Require.h>
// int callback(lua_State *L)
// {
// 	// std::cout << "callback:entered" << std::endl;
//     auto root = *(static_cast<hx::Object ***>(lua_touserdatatagged(L,
// 								  	 			lua_upvalueindex(1), 1)));
//     // std::cout << "callback:root:" << root << std::endl;
//     // std::cout << "callback:*root:" << *root << std::endl;
//     auto cb = Dynamic(*root);
//     // std::cout << "about call cb()" << std::endl;
// 	// std::cout << "callback:L:" << L << std::endl;
// 	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);
//     int rv = cb(statePtr);
//     return rv;
// }
// void gcroot_finalizer (lua_State *L, void *ud) {
// 	// std::cout << "gcroot_finalizer:entered" << std::endl;
// 	auto root = *(static_cast<hx::Object ***>(ud));
//     GCRemoveRoot(root);
//     // std::cout << "gcroot_finalizer:about to call delete root" << std::endl;
// 	// std::cout << "gcroot_finalizer:root:" << root << std::endl;
//     delete root;
// }
// void require_config_init(luarequire_Configuration* config)
// {
//     std::cout << "init got called" << std::endl;
// 	// lua_setuserdatadtor(L, 1, gcroot_finalizer);
//     // hx::Object **root = new hx::Object *{cb.mPtr};
//     // GCAddRoot(root);
//     // // std::cout << "wrapper:cb.mPtr:" << cb.mPtr << std::endl;
//     // // std::cout << "wrapper:root:" << root << std::endl;
//     // // std::cout << "wrapper:*root:" << *root << std::endl;
//     // hx::Object ** *ud = static_cast<hx::Object ***>(lua_newuserdatatagged(L, sizeof(hx::Object **), 1));
// 	// *ud = root;
//     // lua_pushcclosure(L, callback, debugName, 1);
// }
// ')
// @:headerCode('
// #include <Require.h>
// /// @brief This is a C++ wrapper around the C function lua_pushcclosure().
// /// It accepts a Haxe Dynamic function object to pass to lua_pushcclosure().
// /// @param fn The Haxe Dynamic function object to be called back from
// ///           lua_pushcclosure(). The function signature is not constrained
// ///	          here but must match the form expected by lua_pushcclosure().
// void require_config_init(luarequire_Configuration* config);
// ')
// @:keep
// class RequireConfiguratorHidden {}
// @:include("RequireConfiguratorHidden.h")
// extern class RequireConfigurator {
// 	@:native("RequireConfiguratorHidden::require_config_init")
// 	static function requireConfigInit(config:cpp.RawPointer<Configuration>):Void;
// }
