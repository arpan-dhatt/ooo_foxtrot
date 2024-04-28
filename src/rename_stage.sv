module rename_stage #(
    parameter MAX_OPERANDS=3,
    parameter ARN_BITS=6,
    parameter FU_COUNT=4,
    parameter PRN_BITS = 6,
    parameter INST_ID_BITS = 6
) (
    input logic clk,
    input logic rst,

    // from fetch/decode stage
    input logic instr_valid,
    input logic [31:0] in_raw_instr,
    input logic [63:0] in_instr_pc,
    input logic [FUC_BITS-1:0] in_fu_choice,
    input logic [ARN_BITS-1:0] arn_inputs[MAX_OPERANDS],
    input logic [ARN_BITS-1:0] arn_outputs[MAX_OPERANDS],

    // Available new instruction ID from ROB
    input logic [INST_ID_BITS-1:0] new_inst_id,

    // PRN's being freed by ROB
    input logic free_valid[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] free_prns[MAX_OPERANDS],

    // Ready bits being received for PRN's
    input logic set_prn_ready_valid[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] set_prn_ready[MAX_OPERANDS],

    // TODO: handle physical register structural hazards (stall fe/d)
    // TODO: gotta handle rollback too
    // MODULE OUTPUTS
    output logic mapping_valid,
    // combinational output valid for ROB
    output logic mapping_valid_comb,
    // pass through
    output logic [INST_ID_BITS-1:0] inst_id,
    output logic [31:0] raw_instr,
    output logic [63:0] instr_pc,
    output logic [FUC_BITS-1:0] fu_choice,
    // Instruction inputs/outputs renamed
    output logic prn_input_valid[MAX_OPERANDS],
    output logic prn_input_ready[MAX_OPERANDS],
    output logic [PRN_BITS-1:0] prn_input[MAX_OPERANDS],
    output logic prn_output_valid[MAX_OPERANDS],
    output logic [PRN_BITS-1:0] prn_output[MAX_OPERANDS],

    // stuff overwritten by instruction for the ROB (will commit them)
    output logic mapping_inputs_valid[MAX_OPERANDS],
    output logic [PRN_BITS-1:0] mapping_inputs_prn[MAX_OPERANDS],
    output logic [ARN_BITS-1:0] mapping_inputs_arn[MAX_OPERANDS]
);

localparam FUC_BITS = $clog2(FU_COUNT);

// Intermediate variables for renamer module inputs/outputs
logic renamer_mapping_valid;
logic renamer_prn_input_valid[MAX_OPERANDS];
logic renamer_prn_input_ready[MAX_OPERANDS];
logic [PRN_BITS-1:0] renamer_prn_input[MAX_OPERANDS];
logic renamer_prn_output_valid[MAX_OPERANDS];
logic [PRN_BITS-1:0] renamer_prn_output[MAX_OPERANDS];
logic renamer_mapping_inputs_valid[MAX_OPERANDS];
logic [PRN_BITS-1:0] renamer_mapping_inputs_prn[MAX_OPERANDS];
logic [ARN_BITS-1:0] renamer_mapping_inputs_arn[MAX_OPERANDS];

always_comb
begin
    mapping_valid_comb = renamer_mapping_valid;
end

rename #(ARN_BITS, PRN_BITS, MAX_OPERANDS) renamer (
    .clk(clk),
    .rst(rst),

    .input_valid(instr_valid),
    .arn_input(arn_inputs),
    .arn_output(arn_outputs),

    .free_valid(free_valid),
    .free_prns(free_prns),

    .set_prn_ready_valid(set_prn_ready_valid),
    .set_prn_ready(set_prn_ready),

    .prn_input_valid(renamer_prn_input_valid),
    .prn_input_ready(renamer_prn_input_ready),
    .prn_input(renamer_prn_input),

    .prn_output_valid(renamer_prn_output_valid),
    .prn_output(renamer_prn_output),

    .mapping_valid(renamer_mapping_valid),

    .mapping_inputs_valid(renamer_mapping_inputs_valid),
    .mapping_inputs_prn(renamer_mapping_inputs_prn),
    .mapping_inputs_arn(renamer_mapping_inputs_arn)
);

always_ff @(posedge clk) begin
    if (rst) begin
        // Reset outputs
        mapping_valid <= 0;
        inst_id <= 0;
        raw_instr <= 0;
        instr_pc <= 0;
        fu_choice <= 0;
        for (int i = 0; i < MAX_OPERANDS; i++) begin
            prn_input_valid[i] <= 0;
            prn_input_ready[i] <= 0;
            prn_input[i] <= 0;
            prn_output_valid[i] <= 0;
            prn_output[i] <= 0;
            mapping_inputs_valid[i] <= 0;
            mapping_inputs_prn[i] <= 0;
            mapping_inputs_arn[i] <= 0;
        end
    end else begin
        // Set outputs based on the renamer module's outputs
        mapping_valid <= renamer_mapping_valid;
        inst_id <= new_inst_id;
        raw_instr <= in_raw_instr;
        instr_pc <= in_instr_pc;
        fu_choice <= in_fu_choice;
        for (int i = 0; i < MAX_OPERANDS; i++) begin
            prn_input_valid[i] <= renamer_prn_input_valid[i];
            prn_input_ready[i] <= renamer_prn_input_ready[i];
            prn_input[i] <= renamer_prn_input[i];
            prn_output_valid[i] <= renamer_prn_output_valid[i];
            prn_output[i] <= renamer_prn_output[i];
            mapping_inputs_valid[i] <= renamer_mapping_inputs_valid[i];
            mapping_inputs_prn[i] <= renamer_mapping_inputs_prn[i];
            mapping_inputs_arn[i] <= renamer_mapping_inputs_arn[i];
        end
    end
end

endmodule
