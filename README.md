# OoO Processor

This repository contains an out-of-order (OoO) processor implemented in SystemVerilog. The project uses CMake as the
build system and Verilator for SystemVerilog simulation.

## Prerequisites

Before building and running the project, make sure you have the following dependencies installed:

- CMake (version 3.27 or higher)
- Verilator
- C++ compiler supporting C++17
- `ld.lld`: installable via apt on linux or `brew install llvm` on macOS

## Building the Project

To build the project, follow these steps:

1. Clone the repository and init submodules:

```
git clone <repository_url>
cd ooo_foxtrot
git submodule update --init --recursive
```

2. Create a build directory and navigate to it:

```
mkdir build
cd build
```

3. Run CMake to generate the build files:

```
cmake ..
```

4. Build the project:

```
cmake --build .
```

This will compile the SystemVerilog sources and generate the executable files for the testbenches.

## Running Testbenches

After building the project, you can run the testbenches:

- To run the example testbench:

```
./Vexample
```

- To run the cpu testbench:

```
./Vcpu ../testcases/example
```

The testbenches will simulate the respective SystemVerilog modules and display the simulation results.

## Adding More Testbenches

To add a new testbench to the project, follow these steps:

1. Create a new C++ testbench file in the `testbenches` directory, for example, `testbenches/new_testbench.cpp`.
2. In the `CMakeLists.txt` file, add the following lines to define the new testbench executable and its corresponding
   SystemVerilog sources. Add any additional `.cpp` files that are needed to compile the executable, if necessary (
   e.g. `testbenches/support/memory.cpp`):

```cmake
add_executable(Vnew_testbench testbenches/new_testbench.cpp)
verilate(Vnew_testbench SOURCES src/new_module.sv INCLUDE_DIRS src/ TOP new_module)
```

3. Save the `CMakeLists.txt` file.
4. Rebuild the project by running `cmake --build .` in the build directory.

```
./Vnew_testbench
```

## Testcases

Testcases are available in `testcases/` directory with an additional `README.md` for their format. They can be passed
into the `Vcpu` testbench to load and run the CPU.