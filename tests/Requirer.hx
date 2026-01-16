package;

import Lua.CSizeT;
import Lua.NativeState;
import Lua.Ref;
import Lua.State;
import LuaCode.CompileOptions;
import Require.NavigateResult;
import Require.WriteResult;
import Require;
import Types.CString;
import VFSNavigator.NavigationStatus;
import cpp.Star;
import sys.FileSystem;
import sys.io.File;

typedef BoolCheck = () -> Bool;
typedef Coverage = (lua_State:State, int:Int) -> Void;

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
	public var vfs:VFSNavigator;

	static function convert(status:NavigationStatus):NavigateResult {
		return switch (status) {
			case Success: NavigateResult.SUCCESS;
			case Ambiguous: NavigateResult.AMBIGUOUS;
			case NotFound: NavigateResult.NOT_FOUND;
		}
	}

	static function isRequireAllowed(L:cpp.RawPointer<NativeState>, ctx:cpp.RawPointer<cpp.Void>, requirerChunkname:CString):Bool {
		trace("isRequireAllowed got called");
		var chunkname:String = requirerChunkname;
		return chunkname == "=stdin" || (chunkname.length > 0 && chunkname.charAt(0) == '@');
	}

	static function reset(L:State, ctx:cpp.Star<Dynamic>, requirerChunkname:CString):NavigateResult {
		var req:Requirer = cast cpp.Pointer.fromStar(ctx).value;
		var chunkname:String = requirerChunkname;
		if (chunkname == "=stdin") {
			return convert(req.vfs.resetToStdIn());
		} else if (chunkname.length > 0 && chunkname.charAt(0) == '@') {
			return convert(req.vfs.resetToPath(chunkname.substr(1)));
		}
		return NavigateResult.NOT_FOUND;
	}

	static function jumpToAlias(L:State, ctx:cpp.Star<Dynamic>, path:CString):NavigateResult {
		var req:Requirer = cast cpp.Pointer.fromStar(ctx).value;
		var pathStr:String = path;
		// TODO: check if absolute
		return convert(req.vfs.resetToPath(pathStr));
	}

	static function toParent(L:State, ctx:cpp.Star<Dynamic>):NavigateResult {
		var req:Requirer = cast cpp.Pointer.fromStar(ctx).value;
		return convert(req.vfs.toParent());
	}

	static function toChild(L:State, ctx:cpp.Star<Dynamic>, name:CString):NavigateResult {
		var req:Requirer = cast cpp.Pointer.fromStar(ctx).value;
		var nameStr:String = name;
		return convert(req.vfs.toChild(nameStr));
	}

	static function isModulePresent(L:State, ctx:cpp.Star<Dynamic>):Bool {
		var req:Requirer = cast cpp.Pointer.fromStar(ctx).value;
		var path = req.vfs.getFilePath();
		return FileSystem.exists(path) && !FileSystem.isDirectory(path);
	}

	static function getChunkname(L:State, ctx:cpp.Star<Dynamic>, buffer:cpp.Star<cpp.Char>, bufferSize:CSizeT, sizeOut:Ref<CSizeT>):WriteResult {
		var req:Requirer = cast cpp.Pointer.fromStar(ctx).value;
		var content = "@" + req.vfs.getFilePath();
		return write(content, buffer, bufferSize, sizeOut);
	}

	static function getLoadname(L:State, ctx:cpp.Star<Dynamic>, buffer:cpp.Star<cpp.Char>, bufferSize:CSizeT, sizeOut:Ref<CSizeT>):WriteResult {
		var req:Requirer = cast cpp.Pointer.fromStar(ctx).value;
		var content = req.vfs.getAbsoluteFilePath();
		return write(content, buffer, bufferSize, sizeOut);
	}

	static function getCacheKey(L:State, ctx:cpp.Star<Dynamic>, buffer:cpp.Star<cpp.Char>, bufferSize:CSizeT, sizeOut:Ref<CSizeT>):WriteResult {
		var req:Requirer = cast cpp.Pointer.fromStar(ctx).value;
		var content = req.vfs.getAbsoluteFilePath();
		return write(content, buffer, bufferSize, sizeOut);
	}

	static function isConfigPresent(L:State, ctx:cpp.Star<Dynamic>):Bool {
		var req:Requirer = cast cpp.Pointer.fromStar(ctx).value;
		var path = req.vfs.getLuaurcPath();
		return FileSystem.exists(path) && !FileSystem.isDirectory(path);
	}

	static function getConfig(L:State, ctx:cpp.Star<Dynamic>, buffer:cpp.Star<cpp.Char>, bufferSize:CSizeT, sizeOut:Ref<CSizeT>):WriteResult {
		var req:Requirer = cast cpp.Pointer.fromStar(ctx).value;
		var path = req.vfs.getLuaurcPath();
		var content = FileSystem.exists(path) ? File.getContent(path) : null;
		return write(content, buffer, bufferSize, sizeOut);
	}

	static function load(L:State, ctx:cpp.Star<Dynamic>, path:CString, chunkname:CString, loadname:CString):Int {
		// Simplified, need to implement full loading logic
		return 0;
	}

	static function write(content:String, buffer:cpp.Star<cpp.Char>, bufferSize:CSizeT, sizeOut:Ref<CSizeT>):WriteResult {
		if (content == null)
			return WriteResult.FAILURE;
		var nullTerminatedSize = content.length + 1;
		if (bufferSize < nullTerminatedSize) {
			sizeOut = nullTerminatedSize;
			return WriteResult.BUFFER_TOO_SMALL;
		}
		sizeOut = nullTerminatedSize;
		// TODO: copy to buffer
		return WriteResult.SUCCESS;
	}

	public static function requireConfigInit(config:cpp.Star<Configuration>) {
		if (config == null)
			return;
		config.is_require_allowed = cpp.Callable.fromStaticFunction(Requirer.isRequireAllowed).call;
		/*
			config.reset = reset;
			config.jump_to_alias = jumpToAlias;
			config.to_parent = toParent;
			config.to_child = toChild;
			config.is_module_present = isModulePresent;
			config.is_config_present = isConfigPresent;
			config.get_chunkname = getChunkname;
			config.get_loadname = getLoadname;
			config.get_cache_key = getCacheKey;
			config.get_alias = null;
			config.get_config = getConfig;
			config.load = load;
		 */
	}
}
