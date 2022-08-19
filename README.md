# first-test

Uses vcpkg to manage boost-test dependency.

```
\> cd first-test
\> git clone https://github.com/Microsoft/vcpkg.git
\> .\vcpkg\bootstrap-vcpkg.bat
\> cd build
\> cmake .. -DCMAKE_TOOLCHAIN_FILE=<project path>\vcpkg\scripts\buildsystems\vcpkg.cmake
\> cmake --build .
\> test\Debug\first_test.exe
```
