# Haxe Luau Library

This library makes the Roblox open source Luau Lua VM available in Haxe.

# Building

After cloning.

## Build Luau

cd luau
mkdir cmake
cd cmake

cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build . --target Luau.VM --config RelWithDebInfo
cmake --build . --target Luau.Compiler --config RelWithDebInfo