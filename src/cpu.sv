module cpu(
    input logic clk,                // Clock signal
    input logic rst,                // Reset signal
    output logic done,              // Indicates when the CPU has finished execution
    output logic mem_ren,           // Memory read enable signal
    output logic [63:0] mem_raddr,  // Memory read address
    input logic mem_rvalid,         // Indicates when memory read data is valid
    input logic [63:0] mem_rdata,   // Memory read data
    output logic mem_wen,           // Memory write enable signal
    output logic [63:0] mem_waddr,  // Memory write address
    output logic [63:0] mem_wdata,  // Memory write data

    // additional memory ports for fetch
    output logic mem_iren,           // Memory read enable signal
    output logic [63:0] mem_iraddr,  // Memory read address
    input logic mem_irvalid,         // Indicates when memory read data is valid
    input logic [63:0] mem_irdata   // Memory read data
);

localparam MAX_OPERANDS=3;
localparam ARN_BITS=6;
localparam FU_COUNT=4;
localparam FUC_BITS = $clog2(FU_COUNT);
localparam PRN_BITS = 6;
localparam INST_ID_BITS = 6;

// physical register file

localparam OP_R_PORTS = FU_COUNT;
localparam OP_W_PORTS = FU_COUNT;
logic prf_ren[MAX_OPERANDS][OP_R_PORTS];
logic [PRN_BITS-1:0] prf_rprn[MAX_OPERANDS][OP_R_PORTS];
logic [63:0] prf_rdata[MAX_OPERANDS][OP_R_PORTS];
logic prf_wen[MAX_OPERANDS][OP_W_PORTS];
logic [PRN_BITS-1:0] prf_wprn[MAX_OPERANDS][OP_W_PORTS];
logic [63:0] prf_wdata[MAX_OPERANDS][OP_W_PORTS];
prf #(OP_R_PORTS, OP_W_PORTS) reg_file (
    .clk(clk),
    .rst(rst),

    .op_ren(prf_ren),
    .op_rprn(prf_rprn),
    .op_rdata(prf_rdata),

    .op_wen(prf_wen),
    .op_wprn(prf_wprn),
    .op_wdata(prf_wdata)
);

// Fed stage signals
// inputs
logic fed_set_pc_valid;
logic [63:0] fed_set_pc;
// outputs
logic fed_output_valid;
logic [31:0] fed_raw_instr;
logic [63:0] fed_instr_pc;
logic [FUC_BITS-1:0] fed_fu_choice;
logic [ARN_BITS-1:0] fed_arn_inputs[MAX_OPERANDS];
logic [ARN_BITS-1:0] fed_arn_outputs[MAX_OPERANDS];

// Renamer to ROB signals
logic renamer_to_rob_mapping_inputs_valid[MAX_OPERANDS];
logic [PRN_BITS-1:0] renamer_to_rob_mapping_inputs_prn[MAX_OPERANDS];
logic [5:0] renamer_to_rob_mapping_inputs_arn[MAX_OPERANDS];
logic [INST_ID_BITS-1:0] rob_to_renamer_new_inst_id;

// Renamer to issue queue signals
logic renamer_output_valid;
logic renamer_output_valid_comb;
logic [INST_ID_BITS-1:0] renamer_inst_id;
logic [31:0] renamer_raw_instr;
logic [63:0] renamer_instr_pc;
logic [FUC_BITS-1:0] renamer_fu_choice;
logic renamer_prn_input_valid[MAX_OPERANDS];
logic renamer_prn_input_ready[MAX_OPERANDS];
logic [PRN_BITS-1:0] renamer_prn_input[MAX_OPERANDS];
logic renamer_prn_output_valid[MAX_OPERANDS];
logic [PRN_BITS-1:0] renamer_prn_output[MAX_OPERANDS];

// ready bit signals from FU's
logic fus_prn_ready_valid[MAX_OPERANDS];
logic [PRN_BITS-1:0] fus_prn_ready[MAX_OPERANDS];

// ROB to Renamer signals
logic rob_to_renamer_freed_prns_valid[MAX_OPERANDS];
logic [PRN_BITS-1:0] rob_to_renamer_freed_prns[MAX_OPERANDS];

// FU to ROB signals
logic fu_to_rob_out_inst_valid[FU_COUNT];
logic [INST_ID_BITS-1:0] fu_to_rob_out_inst_ids[FU_COUNT];

// ROB to LSU signals
logic rob_to_lsu_retire_inst_valid;
logic [INST_ID_BITS-1:0] rob_to_lsu_retire_inst_id;
logic rob_to_lsu_retire_inst_flush;

// Control flow to ROB signals
logic control_to_rob_start_flush;
logic [INST_ID_BITS-1:0] control_to_rob_start_flush_to;

// ROB to Remap File (inside renamer) signals
logic rob_to_remap_reset_valid[MAX_OPERANDS];
logic [5:0] rob_to_remap_arn_reset[MAX_OPERANDS];
logic [PRN_BITS-1:0] rob_to_remap_prn_reset[MAX_OPERANDS];

// ROB to Renamer stall signal
logic rob_to_renamer_stall_rename;

// Inst ready from ROB?
logic rob_inst_ready;

fed_stage fed (
    .clk(clk),
    .rst(rst),

    .mem_ren(mem_iren),
    .mem_raddr(mem_iraddr),
    .mem_rvalid(mem_irvalid),
    .mem_rdata(mem_irdata),

    .set_pc_valid(fed_set_pc_valid),
    .set_pc(fed_set_pc),

    .output_valid(fed_output_valid),
    .raw_instr(fed_raw_instr),
    .instr_pc(fed_instr_pc),
    .fu_choice(fed_fu_choice),
    .arn_inputs(fed_arn_inputs),
    .arn_outputs(fed_arn_outputs)
);

rename_stage renamer (
    .clk(clk),
    .rst(rst),

    // renamer inputs from fed
    .instr_valid(fed_output_valid),
    .in_raw_instr(fed_raw_instr),
    .in_instr_pc(fed_instr_pc),
    .in_fu_choice(fed_fu_choice),
    .arn_inputs(fed_arn_inputs),
    .arn_outputs(fed_arn_outputs),
    // rob sends new instruction id
    .new_inst_id(rob_to_renamer_new_inst_id),

    // PRN's being freed by ROB
    .free_valid(rob_to_renamer_freed_prns_valid),
    .free_prns(rob_to_renamer_freed_prns),

    // ready bits received from retire queue
    .set_prn_ready_valid(fus_prn_ready_valid),
    .set_prn_ready(fus_prn_ready),

    // renamer outputs
    .mapping_valid(renamer_output_valid),
    .mapping_valid_comb(renamer_output_valid_comb),
    .inst_id(renamer_inst_id),
    .raw_instr(renamer_raw_instr),
    .instr_pc(renamer_instr_pc),
    .fu_choice(renamer_fu_choice),
    .prn_input_valid(renamer_prn_input_valid),
    .prn_input_ready(renamer_prn_output_valid),
    .prn_input(renamer_prn_input),
    .prn_output_valid(renamer_prn_output_valid),
    .prn_output(renamer_prn_output),

    // stuff overwritten by instruction for ROB (will commit)
    .mapping_inputs_valid(renamer_to_rob_mapping_inputs_valid),
    .mapping_inputs_prn(renamer_to_rob_mapping_inputs_prn),
    .mapping_inputs_arn(renamer_to_rob_mapping_inputs_arn)

    //TODO:  .stall_rename(rob_to_renamer_stall_rename)
);

rob reorder_buffer (
    .clk(clk),
    .rst(rst),

    // Renamer dispatch
    .inst_valid(renamer_output_valid_comb),
    .inst_ready(rob_inst_ready),
    .pc(renamer_instr_pc),
    .mapping_inputs_valid(renamer_to_rob_mapping_inputs_valid),
    .mapping_inputs_prn(renamer_to_rob_mapping_inputs_prn),
    .mapping_inputs_arn(renamer_to_rob_mapping_inputs_arn),
    .new_inst_id(rob_to_renamer_new_inst_id),

    // Freed prns for the renamer
    .freed_prns_valid(rob_to_renamer_freed_prns_valid),
    .freed_prns(rob_to_renamer_freed_prns),

    // From FUs
    .fu_out_inst_valid(fu_to_rob_out_inst_valid),
    .fu_out_inst_ids(fu_to_rob_out_inst_ids),

    // To LSU, for when to retire stores
    .retire_inst_valid(rob_to_lsu_retire_inst_valid),
    .retire_inst_id(rob_to_lsu_retire_inst_id),
    .retire_inst_flush(rob_to_lsu_retire_inst_flush),

    // From control flow to trigger a flush
    .start_flush(control_to_rob_start_flush),
    .start_flush_to(control_to_rob_start_flush_to),

    // To the remap file, for undoing mappings because of a flush
    .reset_valid(rob_to_remap_reset_valid),
    .arn_reset(rob_to_remap_arn_reset),
    .prn_reset(rob_to_remap_prn_reset),

    // For when we are flushing, we don't want to rename until we reset our mappings
    .stall_rename(rob_to_renamer_stall_rename)
);

// cycle counter
int c = 0;
always @(posedge clk) begin
    c <= c + 1;
    $display("------------------------------");
    $display("Cycle %d:", c);
    if (fed_output_valid) begin
        $display("FED Outputs:");
        $display("  Raw Instruction: %h", fed_raw_instr);
        $display("  Instruction PC: %h", fed_instr_pc);
        $display("  FU Choice: %d", fed_fu_choice);

        $display("  ARN Inputs: {%d, %d, %d}",
                    fed_arn_inputs[0],
                    fed_arn_inputs[1],
                    fed_arn_inputs[2]);

        $display("  ARN Outputs: {%d, %d, %d}",
                    fed_arn_outputs[0],
                    fed_arn_outputs[1],
                    fed_arn_outputs[2]);

        $display("------------------------------");
    end

    if (renamer_output_valid) begin
        $display("Renamer Outputs:");
        $display("  Instruction ID: %d", renamer_inst_id);
        $display("  Raw Instruction: %h", renamer_raw_instr);
        $display("  Instruction PC: %h", renamer_instr_pc);
        $display("  FU Choice: %d", renamer_fu_choice);

        $display("  PRN Inputs: {Valid: {%b, %b, %b}, Ready: {%b, %b, %b}, PRN: {%d, %d, %d}}",
                 renamer_prn_input_valid[0], renamer_prn_input_valid[1], renamer_prn_input_valid[2],
                 renamer_prn_input_ready[0], renamer_prn_input_ready[1], renamer_prn_input_ready[2],
                 renamer_prn_input[0], renamer_prn_input[1], renamer_prn_input[2]);

        $display("  PRN Outputs: {Valid: {%b, %b, %b}, PRN: {%d, %d, %d}}",
                 renamer_prn_output_valid[0], renamer_prn_output_valid[1], renamer_prn_output_valid[2],
                 renamer_prn_output[0], renamer_prn_output[1], renamer_prn_output[2]);

        $display("------------------------------");
    end

end

endmodule
