# vcpkg boost example

Minimal example that uses vcpkg to manage boost dependencies.

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

1. Install and bootstrap vcpkg
```
\> cd first-test
\> erase vcpkg.json
\> git clone https://github.com/Microsoft/vcpkg.git
\> .\vcpkg\bootstrap-vcpkg.bat
```

2. Install dependencies
```
\> cd vcpkg
\> vcpkg install boost-test:x64-windows
```

3. Build and run project
```
\> cd ..\build
\> cmake .. -DCMAKE_TOOLCHAIN_FILE=<project path>\vcpkg\scripts\buildsystems\vcpkg.cmake
\> cmake --build .
\> test\Debug\first_test.exe
```

## Binary Caching

0. vcpkg and boost-test installed (classic mode)

1. Export dependencies to package
```
\> vcpkg export boost-test:x64-windows --nuget
```

2. Setup local package store 
```
\> vcpkg fetch nuget
\> nuget add <package name>.<version>.nuget -Source <store path>\local-store
```

3. Install dependencies from package
```
\> nuget install <package name> -Source <store path>\local-store 
```

4. Build and run project (Note change in toolchain path)
```
\> cd ..\build
\> cmake .. -DCMAKE_TOOLCHAIN_FILE=<project path>\vcpkg\<package name>\scripts\buildsystems\vcpkg.cmake
\> cmake --build .
\> test\Debug\first_test.exe
```

## GitHub Packages
