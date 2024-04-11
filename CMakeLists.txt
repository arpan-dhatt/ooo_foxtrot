cmake_minimum_required(VERSION 3.27)
project(ooo_foxtrot)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(verilator HINTS $ENV{VERILATOR_ROOT})
add_subdirectory(ext/ELFIO)

add_executable(Vexample testbenches/example.cpp)
verilate(Vexample SOURCES src/example.sv INCLUDE_DIRS src/ TOP example)

add_executable(Vcpu
        testbenches/cpu.cpp
        testbenches/support/memory.cpp)
target_link_libraries(Vcpu PRIVATE elfio)
target_include_directories(Vcpu PRIVATE ext/ELFIO)
verilate(Vcpu SOURCES src/cpu.sv INCLUDE_DIRS src/ TOP cpu)