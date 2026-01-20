package;

import Lua.State;
import Types.CString;

/**
 * Requirer context object. This stores the state of the requirer between
 * API calls from Luau. Luau passes this to each callback function when
 * invoking operations on the requirer.
 * 
 * This is just a simple example.
 */
class RequireCtx {
	public var vfs:VFSNavigator;

	public var data:RequireCtxData;

	static var is_require_allowed:(State, ctx:RequireCtx, requirerChunkname:String) -> Void;

	var reset:Dynamic;
	var jump_to_alias:Dynamic;
	var to_parent:Dynamic;
	var to_child:Dynamic;
	var is_module_present:Dynamic;
	var is_config_present:Dynamic;
	var get_chunkname:Dynamic;
	var get_loadname:Dynamic;
	var get_cache_key:Dynamic;
	var get_alias:Dynamic;
	var get_config_status:Dynamic;
	var get_config:Dynamic;
	var load:Dynamic;

	public function new() {
		vfs = new VFSNavigator();
		data = new RequireCtxData();

		is_require_allowed = Requirer.isRequireAllowed;
		reset = Requirer.reset;
		// jump_to_alias = Requirer.jumpToAlias;
		to_parent = Requirer.toParent;
		to_child = Requirer.toChild;
		is_module_present = Requirer.isModulePresent;
		// is_config_present = Requirer.isConfigPresent;
		get_chunkname = Requirer.getChunkname;
		get_loadname = Requirer.getLoadname;
		get_cache_key = Requirer.getCacheKey;
		// get_alias = null;
		// get_config = Requirer.getConfig;
		load = Requirer.load;
	}
}
