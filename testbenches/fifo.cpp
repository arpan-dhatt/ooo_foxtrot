#include <verilated.h>
#include <iostream>
#include <vector>
#include <cassert>

#include "Vfifo.h"

#define FIFO_MAX_LEN (64)

struct FIFOCompare {
  VerilatedContext *const contextp;
  Vfifo *const top;

  std::deque<uint8_t> reference;

  FIFOCompare(VerilatedContext *const contextp, Vfifo *const top) : contextp(
      contextp), top(top), reference() {}

  static FIFOCompare init(int argc, char *argv[]) {
      auto *const contextp = new VerilatedContext;
      contextp->commandArgs(argc, argv);
      auto *const top = new Vfifo{contextp};
      return {contextp, top};
  }

  ~FIFOCompare() {
      delete top;
      delete contextp;
  }

  void reset() {
      top->clk = 0;
      top->eval();
      top->rst = 1;
      top->clk = 1;
      top->eval();
      top->rst = 0;
      top->clk = 0;
      top->eval();

      reference.clear();
      for (int i = 0; i < FIFO_MAX_LEN; ++i) {
          reference.push_back(i);
      }
  }

  std::pair<std::array<std::optional<uint8_t>, 3>, bool>
  run(std::array<bool, 3> get, std::array<std::optional<uint8_t>, 3> put_vals) {
      for (int i = 0; i < 3; ++i) {
          top->get_en[i] = get[i];
          top->put_en[i] = put_vals[i].has_value();
          if (put_vals[i].has_value()) {
              top->put[i] = put_vals[i].value();
          }
      }
      // get values at combinational before edge finishing rising
      top->eval();

      std::array<std::optional<uint8_t>, 3> gotten{};
      for (int i = 0; i < 3; ++i) {
          if (get[i]) {
              gotten[i] = top->gotten[i];
          }
      }
      bool gotten_valid = top->gotten_valid;

      int num_get_values = std::count(get.begin(), get.end(), true);
      int num_put_values = std::count_if(put_vals.begin(),
                                         put_vals.end(),
                                         [](const auto &v) { return v.has_value(); });

      for (int i = 0; i < num_get_values && !reference.empty(); ++i) {
          reference.pop_front();
      }
      for (int i = 0; i < num_put_values; ++i) {
          if (put_vals[i].has_value()) {
              reference.push_back(put_vals[i].value());
          }
      }

      // finish cycling clock to change fifo state
      top->clk = 1;
      top->eval();
      top->clk = 0;
      top->eval();

      return {gotten, gotten_valid};
  }
};

int main(int argc, char *argv[]) {
    auto fifo = FIFOCompare::init(argc, argv);

    // Test case 0: Do nothing
    fifo.reset();
    auto [gotten, valid] = fifo.run(
        {false, false, false},
        {std::nullopt, std::nullopt, std::nullopt});

    // Test case 1: Get some values out
    std::tie(gotten, valid) = fifo.run({true, false, true}, {});
    assert(valid);
    assert((gotten
        == std::array<std::optional<uint8_t>, 3>{0, std::nullopt, 1}));

    // Test case 2: Get two out and put two back
    std::tie(gotten, valid) =
        fifo.run({true, false, true}, {0, std::nullopt, 1});
    assert(valid);
    assert((gotten
        == std::array<std::optional<uint8_t>, 3>{2, std::nullopt, 3}));

    std::cout << "All test cases passed!" << std::endl;

    return 0;
}