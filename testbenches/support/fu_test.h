#pragma once

#include <array>
#include <sstream>

/*
 * struct to hold important testcase inputs. Things like instruction and PC
 * are separate since they are loaded from ELF file.
 */
struct testcase_input {
  std::array<uint64_t, 3> operands;
  std::array<uint8_t, 3> out_prn;

  testcase_input(std::array<uint64_t, 3> operands,
                 std::array<uint8_t, 3> out_prn) : operands(operands),
                                                   out_prn(out_prn) {}
  /*
   * this is templated, so you can use this with any verilated module, so long
   * as it has all the struct members that are expected (look at fu_logical_wrap
   * to see exactly what.
   */
  template <typename T>
  void insert(T *fu, uint32_t inst, uint64_t pc) {
      // dummy values
      fu->inst_id = 42;
      fu->inst_valid = true;

      // set raw instruction
      fu->inst = inst;
      fu->pc = pc;
      // set operand data
      for (int i = 0; i < operands.size(); i++) {
          fu->op[i] = operands[i];
          fu->out_prn[i] = out_prn[i];
      }
  }
};

/*
 * struct to hold testcase outputs that are checked
 */
struct testcase_output {
  std::array<uint64_t, 3> fu_out_data;
  std::array<bool, 3> fu_out_data_valid;

  testcase_output(std::array<uint64_t, 3> fu_out_data,
                  std::array<bool, 3> fu_out_data_valid) :
      fu_out_data(fu_out_data),
      fu_out_data_valid(fu_out_data_valid) {}

  template <typename T>
  void check(T *fu, struct testcase_input& input) {
      // ensured certain values were passed through
      if (fu->fu_out_inst_id != 42) {
          throw std::runtime_error("inst_id wasn't 42!!!!");
      }

      // for each possible output data
      for (int i = 0; i < fu_out_data_valid.size(); i++) {
          // fu_out_data_valid should be an exact match
          if (fu_out_data_valid[i] != fu->fu_out_data_valid[i]) {
              throw std::runtime_error(
                  "fu_out_data_valid signals should be an exact match with expected");
          }

          // wherever fu_out_data_valid is true, check the output data and prn
          if (fu_out_data_valid[i]) {
              if (fu_out_data[i] != fu->fu_out_data[i]) {
                  std::ostringstream msg;
                  msg << "fu_out_data[" << i << "](" << fu_out_data[i]
                      << ") != fu->fu_out_data[" << i << "]("
                      << fu->fu_out_data[i] << ")";
                  throw std::runtime_error(msg.str());
              }
              if (input.out_prn[i] != fu->fu_out_prn[i]) {
                  std::ostringstream msg;
                  msg << "inputs.out_prn[" << i << "](" << input.out_prn[i]
                      << ") != fu->fu_out_prn[" << i << "]("
                      << fu->fu_out_prn[i] << ")";
                  throw std::runtime_error(msg.str());
              }
          }
      }
  }
};

struct testcase {
  testcase_input input;
  testcase_output output;

  testcase(testcase_input input, testcase_output output) :
      input(input), output(output) {}
};