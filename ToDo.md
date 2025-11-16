# Stuff to do

## The Lua State typing issue

The primary goal of this extern is to be target independent enough that client code does not have to use target `#if` code. As a result all types need to be wrapped in some way to make sure that the compiler emits the correct code without the client code having to do anything special.

The sticking point is the `lua_State` extern due to its various uses.

There are several constraints here:

   * the type must ultimately compile to `*lua_State` in the final cpp
     * we need an extern class type for `lua_State`
     * we need a pointer type of some kind around it
   * the type needs to be able to be passed via Haxe class constructors
     * this requires that the type be compatible with Dynamic
       * only `cpp.Pointer` is compatible with Dynamic
   * pushcfunction and allied functions require a function argument
     * the type of this is `int (*lua_CFunction)(lua_State* L)`
     * this means the Haxe compiler must emit a correct type
       * this only works for `cpp.Star<State>` types
       * RawPointer won't emit a function definition
       * Pointer will emit a Haxe `::Pointer` class which is not `lua_State*`
   * to have a function to pass to pushcfunction you need a Haxe function
     * it must take an argument of the pointer to State type and return Int
     * this function also must be a static as C pointer cannot capture variables like the object instance for a method, or upvalues for a closure.

