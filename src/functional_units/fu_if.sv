// Functional unit interface

interface fu_if #(
    parameter INST_ID_BITS = 8,
    parameter PRN_BITS = 6,
    parameter MAX_OPERANDS = 3
) (
    input logic clk,
    input logic rst
);

  // Input arguments
  logic [INST_ID_BITS-1:0] inst_id;  // Instruction ID
  logic [31:0] inst;  // Instruction
  logic [63:0] op[MAX_OPERANDS];  // Input operands
  logic [PRN_BITS-1:0] out_prn[MAX_OPERANDS];  // Output physical register numbers
  logic [63:0] pc;  // Program counter
  logic inst_valid;  // Indicates if input data is valid

  // Output struct
  typedef struct {
    logic [PRN_BITS-1:0] prn;    // Output physical register number
    logic [63:0]         data;   // Output data
    logic                valid;  // Output prn/data valid
  } out_t;

  // Output arguments
  out_t out[MAX_OPERANDS];  // Output data and PRNs
  logic [INST_ID_BITS-1:0] out_inst_id;  // Output instruction ID
  logic out_valid;           // FU output valid 

  // Modport for the FU
  modport fu(
      input clk, rst,
      input inst_id, inst, op, out_prn, pc, inst_valid,
      output out, out_inst_id, out_valid
  );

  // Modport for controlling FU
  modport ctrl(
      input clk, rst,
      output inst_id, inst, op, out_prn, pc, inst_valid,
      input out, out_inst_id, out_valid
  );

endinterface
