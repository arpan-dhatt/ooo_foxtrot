module inst_router #(parameter INST_ID_BITS = 6,
                     parameter PRN_BITS = 6,
                     parameter MAX_OPERANDS = 3, 
                     parameter QUEUE_SIZE = 4,
                     parameter FUC_BITS = 2)
    (
    // Instruction passthrough
    input logic [INST_ID_BITS-1:0] input_inst_id,
    input logic [31:0] input_raw_instr,
    input logic [63:0] input_instr_pc,
    input logic [FUC_BITS-1:0] input_fu_choice,
    input logic input_prn_input_valid[MAX_OPERANDS],
    input logic input_prn_input_ready[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] input_prn_input[MAX_OPERANDS],
    input logic input_prn_output_valid[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] input_prn_output[MAX_OPERANDS]

    // output logic [INST_ID_BITS-1:0] output_inst_id,
    // output logic [31:0] output_raw_instr,
    // output logic [63:0] output_instr_pc,
    // output logic [FUC_BITS-1:0] output_fu_choice,
    // output logic output_prn_input_valid[MAX_OPERANDS],
    // output logic output_prn_input_ready[MAX_OPERANDS],
    // output logic [PRN_BITS-1:0] output_prn_input[MAX_OPERANDS],
    // output logic output_prn_output_valid[MAX_OPERANDS],
    // output logic [PRN_BITS-1:0] output_prn_output[MAX_OPERANDS]



    );

    always_comb begin
    end

endmodule: inst_router