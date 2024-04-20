module fu_lsu_wrap #(
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
    input logic mem_rvalid,         // Indicates when memory read data is valid
    input logic [63:0] mem_rdata,

    // Output arguments
    output logic [PRN_BITS-1:0] fu_out_prn[MAX_OPERANDS],
    output logic [63:0] fu_out_data[MAX_OPERANDS],
    output logic fu_out_data_valid[MAX_OPERANDS],
    output logic [INST_ID_BITS-1:0] fu_out_inst_id,
    output logic fu_out_valid,
    output logic fu_ready,
    output logic mem_ren,           // Memory read enable signal
    output logic [63:0] mem_raddr,
    output logic [63:0] mem_waddr,  // Memory write address
    output logic mem_wen,
    output logic [63:0] mem_wdata
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
  assign fu_ready = fu_if_inst.fu_ready;

  // Instantiate the fu_logical module
  fu_lsu fu_lsu_inst (
      .iface(fu_if_inst.fu),
      .mem_ren(mem_ren),
      .mem_raddr(mem_raddr),
      .mem_rvalid(mem_rvalid),
      .mem_rdata(mem_rdata),
      .mem_wen(mem_wen),
      .mem_waddr(mem_waddr),
      .mem_wdata(mem_wdata)
  );

endmodule