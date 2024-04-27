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

add_executable(Vfu_logical
        testbenches/fu_logical.cpp
        testbenches/support/memory.cpp)
target_link_libraries(Vfu_logical PRIVATE elfio)
target_include_directories(Vfu_logical PRIVATE ext/ELFIO)
verilate(Vfu_logical PREFIX Vfu_logical SOURCES ${SV_SOURCES} ${SV_WRAPPERS} TOP_MODULE fu_logical_wrap INCLUDE_DIRS .)

add_executable(Vfu_lsu
        testbenches/fu_lsu.cpp
        testbenches/support/memory.cpp)
target_link_libraries(Vfu_lsu PRIVATE elfio)
target_include_directories(Vfu_lsu PRIVATE ext/ELFIO)
verilate(Vfu_lsu PREFIX Vfu_lsu SOURCES ${SV_SOURCES} ${SV_WRAPPERS} TOP_MODULE fu_lsu_wrap INCLUDE_DIRS .)

add_executable(Vinst_decoder
        testbenches/inst_decoder.cpp
        testbenches/support/memory.cpp)
target_link_libraries(Vinst_decoder PRIVATE elfio)
target_include_directories(Vinst_decoder PRIVATE ext/ELFIO)
verilate(Vinst_decoder PREFIX Vinst_decoder SOURCES ${SV_SOURCES} TOP_MODULE inst_decoder INCLUDE_DIRS .)

add_executable(Vfed_stage
        testbenches/fed_stage.cpp
        testbenches/support/memory.cpp)
target_link_libraries(Vfed_stage PRIVATE elfio)
target_include_directories(Vfed_stage PRIVATE ext/ELFIO)
verilate(Vfed_stage PREFIX Vfed_stage SOURCES ${SV_SOURCES} TOP_MODULE fed_stage INCLUDE_DIRS .)

add_executable(Vrename
        testbenches/rename.cpp)
verilate(Vrename PREFIX Vrename SOURCES ${SV_SOURCES} TOP_MODULE rename INCLUDE_DIRS .)

add_executable(Vfifo
        testbenches/fifo.cpp)
verilate(Vfifo PREFIX Vfifo SOURCES ${SV_SOURCES} TOP_MODULE fifo INCLUDE_DIRS .)