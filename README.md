# Haxe Luau Library

This library makes the Roblox open source Luau Lua VM available in Haxe.

# Building

After cloning.

## Build Luau

This should only need to be done once to get the Luau compiler and VM libraries.

```
cd luau
mkdir cmake
cd cmake

cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build . --target Luau.VM --config RelWithDebInfo
cmake --build . --target Luau.Compiler --config RelWithDebInfo
cmake --build . --target Luau.Require --config RelWithDebInfo
```

## Creating a local haxelib and installing the dependent libraries

The local haxelib should be in the repo top level directory.

```
haxelib newrepo

haxelib install hxcpp
haxelib install utest
haxelib dev luau ..
```

# Building and Running tests

```
cd tests
haxe build.hxml

./export/cpp/TestMain
```