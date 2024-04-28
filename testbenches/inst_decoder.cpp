#include <verilated.h>
#include <sstream>
#include <cassert>
#include <vector>
#include <array>
#include <fstream>
#include <iostream>

#include "Vinst_decoder.h"
#include "support/memory.h"

// #define EXIT_ON_ERROR

struct testcase {
  int fu_choice;
  std::array<int, 3> arn_inputs;
  std::array<int, 3> arn_outputs;

  testcase(int fu_choice,
           std::array<int, 3> arn_inputs,
           std::array<int, 3> arn_outputs) :
      fu_choice(fu_choice), arn_inputs(arn_inputs), arn_outputs(arn_outputs) {}

  void check(Vinst_decoder *fu) const {
      if (fu->fu_choice != fu_choice) {
          std::ostringstream msg;
          msg << "Expected fu_choice " << fu_choice << " got " << fu->fu_choice;
          throw std::runtime_error(msg.str());
      }

      for (int i = 0; i < 3; i++) {
          std::ostringstream msg;
          if (arn_inputs[i] != fu->arn_inputs[i]) {
              msg << "Expected arn_inputs[" << i << "] to be " << arn_inputs[i]
                  << " got " << fu->arn_inputs[i];
              throw std::runtime_error(msg.str());
          }
          if (arn_outputs[i] != fu->arn_outputs[i]) {
              msg << "Expected arn_outputs[" << i << "] to be "
                  << arn_outputs[i] << " got " << fu->arn_outputs[i];
              throw std::runtime_error(msg.str());
          }
      }
  }
};

enum FU_CHOICE {
  FU_LOGICAL = 0,
  FU_LSU = 1,
  FU_ARITH = 2,
  FU_DPI = 3
};

int main(int argc, char **argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <test_directory_path>"
                  << std::endl;
        return 1;
    }

    std::string directory_path = argv[1];
    std::string elf_file_path = directory_path + "/prog.elf";

    auto *const contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    auto *const fu = new Vinst_decoder{contextp};

    // Use dummy memory array to load our ELF into (has instructions we're using)
    // Create memory instance
    constexpr size_t MEMORY_SIZE = 4 * 1024;  // 4 KiB
    constexpr size_t MEMORY_LATENCY = 10;  // 10 cycles latency
    Memory memory(MEMORY_SIZE, MEMORY_LATENCY);

    if (std::ifstream(elf_file_path).good()) {
        std::cout << "Loading ELF file:" << elf_file_path
                  << std::endl;
        memory.load_elf(elf_file_path);
    } else {
        throw std::invalid_argument("ELF file doesn't exist");
    }

    // mapping instruction inputs and expected outputs
    // third operand is always the flag register
    std::vector<testcase> testcases = {
        // MOVK
        testcase(FU_DPI, {62, 62, 62}, {5, 62, 62}),
        testcase(FU_DPI, {62, 62, 62}, {12, 62, 62}),
        testcase(FU_DPI, {62, 62, 62}, {20, 62, 62}),

        // MOVZ
        testcase(FU_DPI, {62, 62, 62}, {3, 62, 62}),
        testcase(FU_DPI, {62, 62, 62}, {8, 62, 62}),
        testcase(FU_DPI, {62, 62, 62}, {15, 62, 62}),

        // ADR
        testcase(FU_DPI, {62, 62, 62}, {10, 62, 62}),
        testcase(FU_DPI, {62, 62, 62}, {7, 62, 62}),
        testcase(FU_DPI, {62, 62, 62}, {18, 62, 62}),

        // ADRP
        testcase(FU_DPI, {62, 62, 62}, {2, 62, 62}),
        testcase(FU_DPI, {62, 62, 62}, {9, 62, 62}),
        testcase(FU_DPI, {62, 62, 62}, {14, 62, 62}),

        // ADD/ADDS
        testcase(FU_ARITH, {5, 62, 62}, {12, 62, 62}),
        testcase(FU_ARITH, {5, 62, 62}, {12, 62, 62}),
        testcase(FU_ARITH, {20, 21, 62}, {3, 62, 32}),

        // SUB/SUBS
        testcase(FU_ARITH, {3, 62, 62}, {1, 62, 62}),
        testcase(FU_ARITH, {3, 62, 62}, {1, 62, 62}),
        testcase(FU_ARITH, {20, 21, 62}, {3, 62, 32}),

        // CMP
        testcase(FU_ARITH, {5, 3, 62}, {63, 62, 32}),

        // STP-LDP
        testcase(FU_LSU, {11, 62, 62}, {10, 9, 62}),
        testcase(FU_LSU, {12, 62, 62}, {10, 9, 62}),

        // LDUR-STUR
        testcase(1, {5, 62, 62}, {13, 62, 62}),
        testcase(1, {5, 62, 62}, {13, 62, 62}),

        // CSEL
        testcase(0, {11, 63, 32}, {14, 62, 62}),
        testcase(0, {11, 12, 32}, {14, 62, 62}),
        testcase(0, {2, 3, 32}, {1, 62, 62}),

        // CSINC/CINC
        testcase(0, {5, 5, 32}, {4, 62, 62}),
        testcase(0, {8, 9, 32}, {7, 62, 62}),
        testcase(0, {11, 12, 32}, {10, 62, 62}),

        // CSINV
        testcase(0, {26, 27, 32}, {25, 62, 62}),
        testcase(0, {29, 30, 32}, {28, 62, 62}),

        // CSNEG
        testcase(0, {10, 63, 32}, {9, 62, 62}),
        testcase(0, {13, 14, 32}, {12, 62, 62}),
        testcase(0, {16, 17, 32}, {15, 62, 62}),

        // MVN
        testcase(0, {63, 25, 62}, {24, 62, 62}),
        testcase(0, {63, 27, 62}, {26, 62, 62}),
        testcase(0, {63, 29, 62}, {28, 62, 62}),

        // ORR
        testcase(0, {1, 63, 62}, {0, 62, 62}),
        testcase(0, {4, 5, 62}, {3, 62, 62}),
        testcase(0, {7, 8, 62}, {6, 62, 62}),

        // EOR
        testcase(0, {10, 11, 62}, {9, 62, 62}),
        testcase(0, {13, 14, 62}, {12, 62, 62}),
        testcase(0, {16, 17, 62}, {15, 62, 62}),

        // AND
        testcase(0, {19, 62, 62}, {18, 62, 62}),
        testcase(0, {21, 62, 62}, {20, 62, 62}),
        testcase(0, {23, 62, 62}, {22, 62, 62}),

        // ANDS (with TST alias)
        testcase(0, {23, 12, 62}, {63, 62, 32}),
        testcase(0, {28, 29, 62}, {27, 62, 32}),
        testcase(0, {1, 2, 62}, {0, 62, 32}),

        // SBFM/ASR
        testcase(0, {12, 62, 62}, {12, 62, 62}),
        testcase(0, {14, 62, 62}, {12, 62, 62}),
        testcase(0, {11, 62, 62}, {12, 62, 62}),

        // UBFM/LSL/LSR
        testcase(0, {24, 62, 62}, {14, 62, 62}),
        testcase(0, {11, 62, 62}, {25, 62, 62}),
        testcase(0, {21, 62, 62}, {21, 62, 62})
    };

    // while loop through instructions starting at 0x8 until halt is reached
    int i = 0;
    uint64_t pc = 0x8;
    uint32_t inst = *(uint32_t *) (memory.data + pc);
    while (inst != 0xd4400000) {
        std::cout << std::dec << "Instr [tc: " << i << "][pc: 0x" << std::hex
                  << pc << "] " << inst << " ";

        // didn't have a corresponding testcase for this instruction from ELF file
        if (i >= testcases.size()) {
            std::cout << "ABORTED (testcases vector exhausted)" << std::endl;
            break;
        }

        // set input ports for fu
        fu->instr_valid = 1;
        fu->raw_instr = inst;

        // evaluate combinational circuit
        fu->eval();

#ifndef EXIT_ON_ERROR
        try {
#endif
        testcases[i].check(fu);
        std::cout << "SUCCESS" << std::endl;
#ifndef EXIT_ON_ERROR
        } catch (const std::runtime_error& err) {
            std::cout << "FAILURE" << std::endl;
            std::cout << "Instruction Decoder Outputs:" << std::dec << std::endl;
            std::cout << "fu_choice: " << static_cast<int>(fu->fu_choice) << std::endl;
            std::cout << "arn_inputs:" << std::endl;
            for (int k = 0; k < 3; k++) {
                std::cout << "  Input " << k << ": " << static_cast<int>(fu->arn_inputs[k]) << std::endl;
            }
            std::cout << "arn_outputs:" << std::endl;
            for (int k = 0; k < 3; k++) {
                std::cout << "  Output " << k << ": " << static_cast<int>(fu->arn_outputs[k]) << std::endl;
            }
            std::cout << "-----------------------------" << std::endl;
        }
#endif

        // advance to next instruction
        pc += 0x4;
        i += 1;
        inst = *(uint32_t *) (memory.data + pc);
    }

    delete fu;
    delete contextp;
}