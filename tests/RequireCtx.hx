package;

/**
 * Requirer context object. This stores the state of the requirer between
 * API calls from Luau. Luau passes this to each callback function when
 * invoking operations on the requirer.
 * 
 * This is just a simple example.
 */
class RequireCtx {
	public var number_of_calls:Int;

	public function new() {
		number_of_calls = 17;
	}
}
