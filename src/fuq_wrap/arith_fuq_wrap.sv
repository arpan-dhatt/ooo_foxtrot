module arith_fuq_wrap #(
    parameter INST_ID_BITS = 6,
    parameter PRN_BITS = 6,
    parameter MAX_OPERANDS = 3,
    parameter FU_COUNT = 4,
    parameter FU_INDEX = 2
    ) (
    input logic clk,
    input logic rst,

    // IQ control
    input logic inst_valid,
    output logic queue_ready,
    
    // Input from instruction router
    input logic [INST_ID_BITS-1:0] inst_id,
    input logic [31:0] raw_instr,
    input logic [63:0] instr_pc,
    input logic prn_input_valid[MAX_OPERANDS],
    input logic prn_input_ready[MAX_OPERANDS], // Ready to read from PRF
    input logic [PRN_BITS-1:0] prn_input[MAX_OPERANDS],
    input logic prn_output_valid[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] prn_output[MAX_OPERANDS],

    // 
    input logic set_prn_ready[FU_COUNT - 1][MAX_OPERANDS],
    input logic [PRN_BITS-1:0] set_prn[FU_COUNT - 1][MAX_OPERANDS],

    // register file ports
    input logic [63:0] prf_op[MAX_OPERANDS],
    output logic prf_read_enable[MAX_OPERANDS],
    output logic [PRN_BITS-1:0] prf_read_prn[MAX_OPERANDS],

    // Output arguments
    output logic [63:0] prf_write[MAX_OPERANDS],
    output logic prf_write_enable[MAX_OPERANDS],
    output logic [PRN_BITS-1:0] prf_write_prn[MAX_OPERANDS],
    output logic [INST_ID_BITS-1:0] fu_out_inst_id,
    output logic fu_out_valid
    );

    localparam FUC_BITS = $clog2(FU_COUNT);

    // Instantiate the fu_if interface
    fu_if #(
        .INST_ID_BITS(INST_ID_BITS),
        .PRN_BITS(PRN_BITS),
        .MAX_OPERANDS(MAX_OPERANDS)
    ) fu_if_inst (
        .clk(clk),
        .rst(rst)
    );

    logic full_set_prn_ready[FU_COUNT][MAX_OPERANDS];
    logic [PRN_BITS-1:0] full_set_prn[FU_COUNT][MAX_OPERANDS];
    always_comb begin
        for(int i = 0; i < FU_COUNT; i++) begin
            if(i == FU_INDEX) begin
                full_set_prn[i] = fu_if_inst.ctrl.fu_out_prn;
                full_set_prn_ready[i] = fu_if_inst.ctrl.fu_out_data_valid;
            end else begin
                full_set_prn[i] = set_prn[FUC_BITS'(i) - (i>FU_INDEX)];
                full_set_prn_ready[i] = set_prn_ready[FUC_BITS'(i) - (i>FU_INDEX)];
            end
        end
    end

    issue_queue #(
        .INST_ID_BITS(INST_ID_BITS),
        .PRN_BITS(PRN_BITS),
        .MAX_OPERANDS(MAX_OPERANDS),
        .QUEUE_SIZE(4),
        .FU_COUNT(FU_COUNT),
        .FU_INDEX(FU_INDEX),
        .IN_ORDER(0)
    ) arith_queue (
        .inst_valid(inst_valid),
        .queue_ready(queue_ready),
        .inst_id(inst_id),
        .raw_instr(raw_instr),
        .instr_pc(instr_pc),
        .prn_input_valid(prn_input_valid),
        .prn_input_ready(prn_input_ready),
        .prn_input(prn_input),
        .prn_output_valid(prn_output_valid),
        .prn_output(prn_output),
        .set_prn_ready(full_set_prn_ready),
        .set_prn(full_set_prn),
        .ctrl(fu_if_inst.ctrl),
        .prf_op(prf_op),
        .prf_read_enable(prf_read_enable),
        .prf_read_prn(prf_read_prn)
    );

    // Instantiate the fu_arith module
    fu_arith fu_arith_inst (
        .fu(fu_if_inst.fu)
    );

    // Connect the output arguments to the physical register file (PRF)
    assign prf_write = fu_if_inst.fu_out_data;
    // make sure to only enable writes if output is also valid
    always_comb begin
        for (int i = 0; i < MAX_OPERANDS; i++) begin
            prf_write_enable[i] = prn_output_valid[i] & fu_out_valid;
        end
    end
    assign prf_write_prn = fu_if_inst.fu_out_prn;
    assign fu_out_inst_id = fu_if_inst.fu_out_inst_id;
    assign fu_out_valid = fu_if_inst.fu_out_valid;

    always_ff @(posedge clk)
    begin
        if (!rst && fu_if_inst.fu_out_valid) begin
            $display("Arith FU Finished Instruction ID: %d", fu_if_inst.fu_out_inst_id);
            $display("  PRN Outputs: {Valid: {%b, %b, %b}, PRN: {%d, %d, %d}}",
                    fu_if_inst.fu.fu_out_data_valid[0], fu_if_inst.fu.fu_out_data_valid[1], fu_if_inst.fu.fu_out_data_valid[2],
                    fu_if_inst.fu.fu_out_prn[0], fu_if_inst.fu.fu_out_prn[1], fu_if_inst.fu.fu_out_prn[2]);
        end
    end

endmodule: arith_fuq_wrap
