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
  std::array<int, 3> lrn_inputs;
  std::array<int, 3> lrn_outputs;

  testcase(int fu_choice,
           std::array<int, 3> lrn_inputs,
           std::array<int, 3> lrn_outputs) :
      fu_choice(fu_choice), lrn_inputs(lrn_inputs), lrn_outputs(lrn_outputs) {}

  void check(Vinst_decoder *fu) const {
      if (fu->fu_choice != fu_choice) {
          std::ostringstream msg;
          msg << "Expected fu_choice " << fu_choice << " got " << fu->fu_choice;
          throw std::runtime_error(msg.str());
      }

      for (int i = 0; i < 3; i++) {
          std::ostringstream msg;
          if (lrn_inputs[i] != fu->lrn_inputs[i]) {
              msg << "Expected lrn_inputs[" << i << "] to be " << lrn_inputs[i]
                  << " got " << fu->lrn_inputs[i];
              throw std::runtime_error(msg.str());
          }
          if (lrn_outputs[i] != fu->lrn_outputs[i]) {
              msg << "Expected lrn_outputs[" << i << "] to be "
                  << lrn_outputs[i] << " got " << fu->lrn_outputs[i];
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
        testcase(FU_DPI, {0, 0, 0}, {5, 0, 0}),
        testcase(FU_DPI, {0, 0, 0}, {12, 0, 0}),
        testcase(FU_DPI, {0, 0, 0}, {20, 0, 0}),

        // MOVZ
        testcase(FU_DPI, {0, 0, 0}, {3, 0, 0}),
        testcase(FU_DPI, {0, 0, 0}, {8, 0, 0}),
        testcase(FU_DPI, {0, 0, 0}, {15, 0, 0}),

        // ADR
        testcase(FU_DPI, {0, 0, 0}, {10, 0, 0}),
        testcase(FU_DPI, {0, 0, 0}, {7, 0, 0}),
        testcase(FU_DPI, {0, 0, 0}, {18, 0, 0}),

        // ADRP
        testcase(FU_DPI, {0, 0, 0}, {2, 0, 0}),
        testcase(FU_DPI, {0, 0, 0}, {9, 0, 0}),
        testcase(FU_DPI, {0, 0, 0}, {14, 0, 0}),

        // ADD/ADDS
        testcase(FU_ARITH, {5, 0, 0}, {12, 0, 0}),
        testcase(FU_ARITH, {5, 0, 0}, {12, 0, 0}),
        testcase(FU_ARITH, {20, 21, 0}, {3, 0, 32}),

        // SUB/SUBS
        testcase(FU_ARITH, {3, 0, 0}, {1, 0, 0}),
        testcase(FU_ARITH, {3, 0, 0}, {1, 0, 0}),
        testcase(FU_ARITH, {20, 21, 0}, {3, 0, 32}),

        // CMP
        testcase(FU_ARITH, {5, 3, 0}, {63, 0, 32}),

        // STP-LDP
        testcase(FU_LSU, {11, 0, 0}, {10, 9, 0}),
        testcase(FU_LSU, {12, 0, 0}, {10, 9, 0}),

        // LDUR-STUR
        testcase(1, {5, 0, 0}, {13, 0, 0}),
        testcase(1, {5, 0, 0}, {13, 0, 0}),

        // CSEL
        testcase(0, {11, 63, 32}, {14, 0, 0}),
        testcase(0, {11, 12, 32}, {14, 0, 0}),
        testcase(0, {2, 3, 32}, {1, 0, 0}),

        // CSINC/CINC
        testcase(0, {5, 5, 32}, {4, 0, 0}),
        testcase(0, {8, 9, 32}, {7, 0, 0}),
        testcase(0, {11, 12, 32}, {10, 0, 0}),

        // CSINV
        testcase(0, {26, 27, 32}, {25, 0, 0}),
        testcase(0, {29, 30, 32}, {28, 0, 0}),

        // CSNEG
        testcase(0, {10, 63, 32}, {9, 0, 0}),
        testcase(0, {13, 14, 32}, {12, 0, 0}),
        testcase(0, {16, 17, 32}, {15, 0, 0}),

        // MVN
        testcase(0, {63, 25, 0}, {24, 0, 0}),
        testcase(0, {63, 27, 0}, {26, 0, 0}),
        testcase(0, {63, 29, 0}, {28, 0, 0}),

        // ORR
        testcase(0, {1, 63, 0}, {0, 0, 0}),
        testcase(0, {4, 5, 0}, {3, 0, 0}),
        testcase(0, {7, 8, 0}, {6, 0, 0}),

        // EOR
        testcase(0, {10, 11, 0}, {9, 0, 0}),
        testcase(0, {13, 14, 0}, {12, 0, 0}),
        testcase(0, {16, 17, 0}, {15, 0, 0}),

        // AND
        testcase(0, {19, 0, 0}, {18, 0, 0}),
        testcase(0, {21, 0, 0}, {20, 0, 0}),
        testcase(0, {23, 0, 0}, {22, 0, 0}),

        // ANDS (with TST alias)
        testcase(0, {23, 12, 0}, {63, 0, 32}),
        testcase(0, {28, 29, 0}, {27, 0, 32}),
        testcase(0, {1, 2, 0}, {0, 0, 32}),

        // SBFM/ASR
        testcase(0, {12, 0, 0}, {12, 0, 0}),
        testcase(0, {14, 0, 0}, {12, 0, 0}),
        testcase(0, {11, 0, 0}, {12, 0, 0}),

        // UBFM/LSL/LSR
        testcase(0, {24, 0, 0}, {14, 0, 0}),
        testcase(0, {11, 0, 0}, {25, 0, 0}),
        testcase(0, {21, 0, 0}, {21, 0, 0})
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
            std::cout << "lrn_inputs:" << std::endl;
            for (int k = 0; k < 3; k++) {
                std::cout << "  Input " << k << ": " << static_cast<int>(fu->lrn_inputs[k]) << std::endl;
            }
            std::cout << "lrn_outputs:" << std::endl;
            for (int k = 0; k < 3; k++) {
                std::cout << "  Output " << k << ": " << static_cast<int>(fu->lrn_outputs[k]) << std::endl;
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