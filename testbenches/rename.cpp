// DESCRIPTION: Verilator: Verilog example module
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2017 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
//======================================================================

// Include common routines
#include <verilated.h>

#include "Vrename.h"

struct RenamerWrap {
  VerilatedContext* const contextp;
  Vrename* const renamer;

  RenamerWrap(VerilatedContext *const PContext, Vrename *const PVrename):
    contextp(PContext), renamer(PVrename) {}

  static RenamerWrap create() {
      auto *const contextp = new VerilatedContext;
      auto *const renamer = new Vrename{contextp};
      return {contextp, renamer};
  }

  void reset() const {
      renamer->clk = 0;
      renamer->eval();
      renamer->clk = 1;
      renamer->rst = 1;
      renamer->eval();
      renamer->clk = 0;
      renamer->rst = 0;
      renamer->eval();
  }

  void set_lrns(const std::array<int, 3>& inputs,
                const std::array<int, 3>& outputs) const {
      for (size_t i = 0; i < inputs.size(); i++) {
          renamer->lrn_input[i] = inputs[i];
          renamer->lrn_output[i] = outputs[i];
      }
      renamer->lrns_valid = true;
  }

  void invalid_lrns() const {
      renamer->lrns_valid = false;
  }

  void set_free_prns(const std::array<std::optional<int>, 6>& free_prns) const {
      for (size_t i = 0; i < free_prns.size(); i++) {
          renamer->free_valid[i] = free_prns[i].has_value();
          renamer->free_prns[i] = free_prns[i].value();
      }
  }

  void invalid_free_prns() const {
      for (unsigned char & i : renamer->free_valid) {
          i = false;
      }
  }

  void cycle() const {
      renamer->clk = 1;
      renamer->eval();
      renamer->clk = 0;
      renamer->eval();
  }

  ~RenamerWrap() {
      delete renamer;
      delete contextp;
  }

};


constexpr int ZERO_LRN = 63;
constexpr int INVALID_LRN = 62;


int main(int argc, char** argv) {
    RenamerWrap renamer = RenamerWrap::create();


    // Reset renamer
    renamer.reset();
    renamer.set_lrns({2, INVALID_LRN, INVALID_LRN},
                     {2, 4, INVALID_LRN});
    renamer.cycle();

    return 0;
}
