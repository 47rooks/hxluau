package;

import Lua.LuaStatus;
import Lua.State;
import LuaCode.CompileOptions;
import Require;
import VFSNavigator.NavigationStatus;
import sys.FileSystem;

/**
 * Implementation of the Requirer.
 */
class Requirer {
	/**
	 * Converts a NavigationStatus to a NavigateResult.
	 * @param status the NavigationStatus to convert
	 * @return the corresponding NavigateResult
	 */
	public static function convert(status:NavigationStatus):NavigateResult {
		return switch (status) {
			case Success: NavigateResult.SUCCESS;
			case Ambiguous: NavigateResult.AMBIGUOUS;
			case NotFound: NavigateResult.NOT_FOUND;
		}
	}

	/**
	 * Returns whether requiring from the given chunkname is allowed.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @param requirerChunkname the chunkname of the requirer
	 * @return true if requiring is allowed, false otherwise
	 */
	public static function isRequireAllowed(L:State, ctx:RequireCtx, requirerChunkname:String):Bool {
		trace("isRequireAllowed got called");
		trace('ctx=${ctx}');
		trace('requirer chunkname=${requirerChunkname}');
		trace('data->number_of_calls=${ctx.number_of_calls}');
		// FIXME define chunkname convention.
		//       Will matter more in flixel/openfl/lime asset context.
		// return chunkname == "=stdin" || (chunkname.length > 0 && chunkname.charAt(0) == '@');
		return true;
	}

	/**
	 * Resets the VFSNavigator to the location specified by the requirerChunkname.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @param requirerChunkname the chunkname of the requirer
	 * @return the result of the navigation
	 */
	public static function reset(L:State, ctx:RequireCtx, requirerChunkname:String):NavigateResult {
		trace('reset got called from chunk: ${requirerChunkname}');
		trace('ctx=${ctx}');

		if (requirerChunkname == "=stdin") {
			return convert(ctx.vfs.resetToStdIn());
		} else if (requirerChunkname.length > 0 && requirerChunkname.charAt(0) == '@') {
			return convert(ctx.vfs.resetToPath(requirerChunkname.substr(1)));
		}
		// This is just a test example where we assume that chunknames
		// are the file names of the loaded Luau code.
		trace('reset calling resetToPath with ${requirerChunkname}');
		trace('ctx=${ctx}');
		trace('ctx.vfs=${ctx.vfs}');
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

	/**
	 * Navigates to the parent directory in the VFSNavigator.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return the result of the navigation
	 */
	public static function toParent(L:State, ctx:RequireCtx):NavigateResult {
		trace('toParent got called ctx=${ctx}');
		var rv = convert(ctx.vfs.toParent());
		trace('toParent returning ${rv}');
		return rv;
	}

	/**
	 * Navigates to the child with the given name in the VFSNavigator.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @param name the name of the child to navigate to
	 * @return the result of the navigation
	 */
	public static function toChild(L:State, ctx:RequireCtx, name:String):NavigateResult {
		trace('toChild called with name=${name}');
		var rv = convert(ctx.vfs.toChild(name));
		trace('toChild returning ${rv}');
		return rv;
	}

	/**
	 * Returns whether a module is present in the current context.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return true if a module is present, false otherwise
	 */
	public static function isModulePresent(L:State, ctx:RequireCtx):Bool {
		var path = ctx.vfs.getFilePath();
		return FileSystem.exists(path) && !FileSystem.isDirectory(path);
	}

	/**
	 * Returns the chunkname for the current module in the VFSNavigator.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return the chunkname
	 */
	public static function getChunkname(L:State, ctx:RequireCtx):String {
		return "@" + ctx.vfs.getFilePath();
	}

	/**
	 * Returns the loadname for the current module in the VFSNavigator.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return the loadname
	 */
	public static function getLoadname(L:State, ctx:RequireCtx):String {
		return ctx.vfs.getAbsoluteFilePath();
	}

	/**
	 * Returns the cache key for the current module in the VFSNavigator.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return the cache key
	 */
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

	/**
	 * Loads and executes the module at the given loadname.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @param path the module path
	 * @param chunkname the chunkname for the module
	 * @param loadname the loadname for the module
	 * @return LUA_OK on success, or an error code on failure
	 */
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
}
