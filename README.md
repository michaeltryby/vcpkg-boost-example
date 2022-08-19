# first-test

Uses vcpkg to manage boost-test dependency.

```
\> cd first-test
\> git clone https://github.com/Microsoft/vcpkg.git
\> .\vcpkg\bootstrap-vcpkg.bat
\> cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=<project path>\vcpkg\scripts\buildsystems\vcpkg.cmake
\> cd build
\> cmake --build .
\> test\Debug\first_test.exe
```
