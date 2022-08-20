# first-test

Example showing how to use vcpkg to manage boost dependencies.

## Manifest Mode

1. Install and bootstrap vcpkg
```
\> cd first-test
\> git clone https://github.com/Microsoft/vcpkg.git
\> .\vcpkg\bootstrap-vcpkg.bat
```

2. Build and run project
```
\> cd build
\> cmake .. -DCMAKE_TOOLCHAIN_FILE=<project path>\vcpkg\scripts\buildsystems\vcpkg.cmake
\> cmake --build .
\> test\Debug\first_test.exe
```


## Classic Mode

1. Install dependencies
```
\> cd vcpkg
\> vcpkg install boost-test:x64-windows
```

2. Export dependencies to package
```
\> vcpkg export boost-test:x64-windows --nuget
```

3. Install dependencies from package
```
\>
```
