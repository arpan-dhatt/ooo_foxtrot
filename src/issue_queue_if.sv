// Issue queue interface


interface issue_queue_if #(
                    parameter INST_ID_BITS = 6,
                    parameter PRN_BITS = 6,
                    parameter MAX_OPERANDS = 3, 
                    parameter QUEUE_SIZE = 4
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

// Output arguments
logic [PRN_BITS-1:0] fu_out_prn[MAX_OPERANDS]; // FU's output prns
logic [63:0] fu_out_data[MAX_OPERANDS]; // resp. output data for prns
logic fu_out_data_valid[MAX_OPERANDS]; // resp. output is valid
logic [INST_ID_BITS-1:0] fu_out_inst_id;  // Output instruction ID
logic fu_out_valid;           // FU output valid
logic fu_ready;               // FU ready to receive instruction

// Modport for the iq
modport iq(
    input clk, rst,
    input inst_id, inst, op, out_prn, pc, inst_valid,
    output fu_out_prn, fu_out_data, fu_out_data_valid, fu_out_inst_id, fu_out_valid, fu_ready
);

// Modport for controlling iq
modport ctrl(
    input clk, rst,
    output inst_id, inst, op, out_prn, pc, inst_valid,
    input fu_out_prn, fu_out_data, fu_out_data_valid, fu_out_inst_id, fu_out_valid, fu_ready
);

endinterface: issue_queue_if
