// Logical FU wrapper to expose fu_if.ctrl for verilator

module fu_logical_wrap #(
    parameter INST_ID_BITS = 6,
    parameter PRN_BITS = 6,
    parameter MAX_OPERANDS = 3
) (
    input logic clk,
    input logic rst,

    // Input arguments
    input logic [INST_ID_BITS-1:0] inst_id,
    input logic [31:0] inst,
    input logic [63:0] op[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] out_prn[MAX_OPERANDS],
    input logic [63:0] pc,
    input logic inst_valid,

    // Output arguments
    output logic [PRN_BITS-1:0] fu_out_prn[MAX_OPERANDS],
    output logic [63:0] fu_out_data[MAX_OPERANDS],
    output logic fu_out_data_valid[MAX_OPERANDS],
    output logic [INST_ID_BITS-1:0] fu_out_inst_id,
    output logic fu_out_valid
);

  // Instantiate the fu_if interface
  fu_if #(
      .INST_ID_BITS(INST_ID_BITS),
      .PRN_BITS(PRN_BITS),
      .MAX_OPERANDS(MAX_OPERANDS)
  ) fu_if_inst (
      .clk(clk),
      .rst(rst)
  );

  // Connect the input arguments to the fu_if.ctrl ports
  assign fu_if_inst.inst_id = inst_id;
  assign fu_if_inst.inst = inst;
  assign fu_if_inst.op = op;
  assign fu_if_inst.out_prn = out_prn;
  assign fu_if_inst.pc = pc;
  assign fu_if_inst.inst_valid = inst_valid;

  // Connect the output arguments from the fu_if.ctrl ports
  assign fu_out_prn = fu_if_inst.fu_out_prn;
  assign fu_out_data = fu_if_inst.fu_out_data;
  assign fu_out_data_valid = fu_if_inst.fu_out_data_valid;
  assign fu_out_inst_id = fu_if_inst.fu_out_inst_id;
  assign fu_out_valid = fu_if_inst.fu_out_valid;

  // Instantiate the fu_logical module
  fu_logical fu_logical_inst (
      .fu(fu_if_inst.fu)
  );

endmodule