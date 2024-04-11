#include <verilated.h>
#include <iostream>
#include <vector>
#include <cstring>
#include <sstream>
#include <fstream>
#include <elfio/elfio.hpp>

#include "Vcpu.h"
#include "support/memory.h"

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <test_directory_path>" << std::endl;
        return 1;
    }

    std::string directory_path = argv[1];
    std::string mem_file_path = directory_path + "/mem.bin";
    std::string mem_cmp_file_path = directory_path + "/mem_cmp.txt";
    std::string mmio_file_path = directory_path + "/mmio.txt";

    auto* const contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    auto* const cpu = new Vcpu{contextp};

    // Create memory instance
    constexpr size_t MEMORY_SIZE = 64 * 1024;  // 64 KiB
    constexpr size_t MEMORY_LATENCY = 10;  // 10 cycles latency
    Memory memory(MEMORY_SIZE, MEMORY_LATENCY);

    // Load memory contents from file if it exists
    if (std::ifstream(mem_file_path).good()) {
        std::cout << "Loading memory from file: " << mem_file_path << std::endl;
        memory.load_from_file(mem_file_path);
    }

    // Reset
    cpu->clk = 0;
    cpu->eval();
    cpu->rst = 1;
    cpu->clk = 1;
    cpu->eval();
    cpu->rst = 0;
    cpu->clk = 0;
    cpu->eval();

    std::ostringstream mmio_output;

    while (!cpu->done) {
        // Cycle clock
        cpu->clk ^= 1;
        cpu->eval();
        cpu->clk ^= 1;
        cpu->eval();

        // Handle memory reads
        if (cpu->mem_ren && cpu->mem_raddr < MEMORY_SIZE) {
            memory.read(cpu->mem_raddr);
        }

        // Handle memory writes
        if (cpu->mem_wen) {
            if (cpu->mem_waddr < MEMORY_SIZE) {
                memory.write(cpu->mem_waddr, cpu->mem_wdata);
            } else if (cpu->mem_waddr == 0xffffffffffffffff) {
                // Write chars from MMIO addr
                char mmio_char = static_cast<char>(cpu->mem_wdata & 0xFF);
                std::cout << mmio_char;
                mmio_output << mmio_char;
            } else {
                std::ostringstream msg;
                msg << "CPU tried to write to invalid addr " << cpu->mem_waddr;
                throw std::out_of_range(msg.str());
            }
        }

        // Update memory
        memory.update();

        // Set the read data and mem_ren signal
        auto read_data = memory.get_read_data();
        if (read_data.has_value()) {
            cpu->mem_rready = 1;
            cpu->mem_rdata = read_data.value();
        } else {
            cpu->mem_rready = 0;
        }
    }

    std::cout << std::endl;

    cpu->final();
    delete cpu;
    delete contextp;

    // Compare memory
    memory.compare_with_file(mem_cmp_file_path);

    // Compare MMIO output
    std::ifstream mmio_file(mmio_file_path);
    if (mmio_file.is_open()) {
        std::string expected_mmio((std::istreambuf_iterator<char>(mmio_file)),
                                  std::istreambuf_iterator<char>());
        if (expected_mmio != mmio_output.str()) {
            std::cout << "MMIO output mismatch!" << std::endl;
            std::cout << "Expected: " << expected_mmio << std::endl;
            std::cout << "Actual: " << mmio_output.str() << std::endl;
        } else {
            std::cout << "MMIO output matches!" << std::endl;
        }
        mmio_file.close();
    } else {
        std::cout << "Unable to open MMIO file: " << mmio_file_path << std::endl;
    }

    return 0;
}