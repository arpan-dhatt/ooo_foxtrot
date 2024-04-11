cmake_minimum_required(VERSION 3.27)
project(ooo_foxtrot)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(verilator HINTS $ENV{VERILATOR_ROOT})
add_subdirectory(ext/ELFIO)

# ======== GET ALL SV SOURCES AND WRAPPERS (wrappers necessary or some TB's) ======== #
file(GLOB_RECURSE SV_SOURCES src/*.sv)
file(GLOB_RECURSE SV_WRAPPERS testbenches/wrap/*.sv)

add_executable(Vexample testbenches/example.cpp)
verilate(Vexample PREFIX Vexample SOURCES ${SV_SOURCES} TOP_MODULE example INCLUDE_DIRS .)

add_executable(Vcpu
        testbenches/cpu.cpp
        testbenches/support/memory.cpp)
target_link_libraries(Vcpu PRIVATE elfio)
target_include_directories(Vcpu PRIVATE ext/ELFIO)
verilate(Vcpu PREFIX Vcpu SOURCES ${SV_SOURCES} TOP_MODULE cpu INCLUDE_DIRS .)

add_executable(Vfu_logical testbenches/fu_logical.cpp)
verilate(Vfu_logical PREFIX Vfu_logical SOURCES ${SV_SOURCES} ${SV_WRAPPERS} TOP_MODULE fu_logical_wrap INCLUDE_DIRS .)