module issue_queue #(parameter INST_ID_BITS = 6,
                     parameter PRN_BITS = 6,
                     parameter MAX_OPERANDS = 3)
    (
    input logic clk,
    input logic rst,

    // Issue queue control
    input logic queue_inst_valid,
    output logic queue_full,

    // Single instruction receive
    input logic [INST_ID_BITS-1:0] inst_id,  // Instruction ID
    input logic [31:0] inst,  // Instruction
    input logic [63:0] op[MAX_OPERANDS],  // Input operands
    input logic [PRN_BITS-1:0] out_prn[MAX_OPERANDS],  // Output physical register numbers
    input logic [63:0] pc,  // Program counter

    // FU control interface
    fu_if.ctrl ctrl

    );




endmodule: issue_queue