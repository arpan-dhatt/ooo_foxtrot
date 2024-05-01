module inst_router #(parameter INST_ID_BITS = 6,
                     parameter PRN_BITS = 6,
                     parameter MAX_OPERANDS = 3, 
                     parameter QUEUE_SIZE = 4,
                     parameter FU_COUNT = 4,
                     parameter FUC_BITS = 2)
    (
    input logic clk,
    input logic rst,

    // Instruction passthrough
    input logic input_inst_valid,
    input logic [INST_ID_BITS-1:0] input_inst_id,
    input logic [31:0] input_raw_instr,
    input logic [63:0] input_instr_pc,
    input logic [FUC_BITS-1:0] input_fu_choice,
    input logic input_prn_input_valid[MAX_OPERANDS],
    input logic input_prn_input_ready[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] input_prn_input[MAX_OPERANDS],
    input logic input_prn_output_valid[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] input_prn_output[MAX_OPERANDS],

    // LSU memory read/write passthrough
    output logic mem_ren,           // Memory read enable signal
    output logic [63:0] mem_raddr,  // Memory read address
    input logic mem_rvalid,         // Indicates when memory read data is valid
    input logic [63:0] mem_rdata,   // Memory read data
    output logic mem_wen,           // Memory write enable signal
    output logic [63:0] mem_waddr,  // Memory write address
    output logic [63:0] mem_wdata,  // Memory write data

    // prn ready bits from all functional units
    output logic set_prn_ready[FU_COUNT][MAX_OPERANDS],
    output logic [PRN_BITS-1:0] set_prn[FU_COUNT][MAX_OPERANDS],

    // whether each functional unit queue has space for another instruction
    output logic queue_ready[FU_COUNT],

    // Register File ports per functional unit
    input logic [63:0] prf_op[FU_COUNT][MAX_OPERANDS],
    output logic prf_read_enable[FU_COUNT][MAX_OPERANDS],
    output logic [PRN_BITS-1:0] prf_read_prn[FU_COUNT][MAX_OPERANDS],
    // register file write ports
    output logic [63:0] prf_write_data[FU_COUNT][MAX_OPERANDS],
    output logic prf_write_enable[FU_COUNT][MAX_OPERANDS],
    output logic [PRN_BITS-1:0] prf_write_prn[FU_COUNT][MAX_OPERANDS],

    // out instruction_ids for each functional unit
    output logic fu_out_inst_valid[FU_COUNT],
    output logic [INST_ID_BITS-1:0] fu_out_inst_ids[FU_COUNT]
);

logic inst_valid_inst_demux[FU_COUNT];
logic [INST_ID_BITS-1:0] inst_id_inst_demux[FU_COUNT];
logic [31:0] raw_instr_inst_demux[FU_COUNT];
logic [63:0] instr_pc_inst_demux[FU_COUNT];
logic prn_input_valid_inst_demux[FU_COUNT][MAX_OPERANDS];
logic prn_input_ready_inst_demux[FU_COUNT][MAX_OPERANDS];
logic [PRN_BITS-1:0] prn_input_inst_demux[FU_COUNT][MAX_OPERANDS];
logic prn_output_valid_inst_demux[FU_COUNT][MAX_OPERANDS];
logic [PRN_BITS-1:0] prn_output_inst_demux[FU_COUNT][MAX_OPERANDS];

// instruction routing
always_comb begin
    for (int i = 0; i < FU_COUNT; i++) begin
        inst_valid_inst_demux[i] = '0;
        inst_id_inst_demux[i] = '0;
        raw_instr_inst_demux[i] = '0;
        instr_pc_inst_demux[i] = '0;
        for (int j = 0; j < MAX_OPERANDS; j++) begin
            prn_input_valid_inst_demux[i][j] = '0;
            prn_input_ready_inst_demux[i][j] = '0;
            prn_input_inst_demux[i][j] = '0;
            prn_output_valid_inst_demux[i][j] = '0;
            prn_output_inst_demux[i][j] = '0;
        end
        if (input_inst_valid) begin
            if (input_fu_choice == FUC_BITS'(i)) begin
                inst_valid_inst_demux[i] = input_inst_valid;
                inst_id_inst_demux[i] = input_inst_id;
                raw_instr_inst_demux[i] = input_raw_instr;
                instr_pc_inst_demux[i] = input_instr_pc;
                for (int j = 0; j < MAX_OPERANDS; j++) begin
                    prn_input_valid_inst_demux[i][j] = input_prn_input_valid[j];
                    prn_input_ready_inst_demux[i][j] = input_prn_input_ready[j];
                    prn_input_inst_demux[i][j] = input_prn_input[j];
                    prn_output_valid_inst_demux[i][j] = input_prn_output_valid[j];
                    prn_output_inst_demux[i][j] = input_prn_output[j];
                end
            end
        end
    end
end

// Logical FU/Q
logical_fuq_wrap #(
    .INST_ID_BITS(INST_ID_BITS),
    .PRN_BITS(PRN_BITS),
    .MAX_OPERANDS(MAX_OPERANDS),
    .FU_COUNT(FU_COUNT),
    .FU_INDEX(0)
) logical_fuq (
    .clk(clk),
    .rst(rst),
    .inst_valid(inst_valid_inst_demux[0]),
    .queue_ready(queue_ready[0]),
    .inst_id(inst_id_inst_demux[0]),
    .raw_instr(raw_instr_inst_demux[0]),
    .instr_pc(instr_pc_inst_demux[0]),
    .prn_input_valid(prn_input_valid_inst_demux[0]),
    .prn_input_ready(prn_input_ready_inst_demux[0]),
    .prn_input(prn_input_inst_demux[0]),
    .prn_output_valid(prn_output_valid_inst_demux[0]),
    .prn_output(prn_output_inst_demux[0]),
    .set_prn_ready(set_prn_ready[1:FU_COUNT-1]),
    .set_prn(set_prn[1:FU_COUNT-1]),
    .prf_op(prf_op[0]),
    .prf_read_enable(prf_read_enable[0]),
    .prf_read_prn(prf_read_prn[0]),
    .prf_write(prf_write_data[0]),
    .prf_write_enable(prf_write_enable[0]),
    .prf_write_prn(prf_write_prn[0]),
    .fu_out_inst_id(fu_out_inst_ids[0]),
    .fu_out_valid(fu_out_inst_valid[0])
);

// LSU FU/Q
lsu_fuq_wrap #(
    .INST_ID_BITS(INST_ID_BITS),
    .PRN_BITS(PRN_BITS),
    .MAX_OPERANDS(MAX_OPERANDS),
    .FU_COUNT(FU_COUNT),
    .FU_INDEX(1)
) lsu_fuq (
    .clk(clk),
    .rst(rst),
    .inst_valid(inst_valid_inst_demux[1]),
    .queue_ready(queue_ready[1]),
    .inst_id(inst_id_inst_demux[1]),
    .raw_instr(raw_instr_inst_demux[1]),
    .instr_pc(instr_pc_inst_demux[1]),
    .prn_input_valid(prn_input_valid_inst_demux[1]),
    .prn_input_ready(prn_input_ready_inst_demux[1]),
    .prn_input(prn_input_inst_demux[1]),
    .prn_output_valid(prn_output_valid_inst_demux[1]),
    .prn_output(prn_output_inst_demux[1]),
    .set_prn_ready({set_prn_ready[0], set_prn_ready[2:FU_COUNT-1]}),
    .set_prn({set_prn[0], set_prn[2:FU_COUNT-1]}),
    .prf_op(prf_op[1]),
    .prf_read_enable(prf_read_enable[1]),
    .prf_read_prn(prf_read_prn[1]),
    .prf_write(prf_write_data[1]),
    .prf_write_enable(prf_write_enable[1]),
    .prf_write_prn(prf_write_prn[1]),
    .fu_out_inst_id(fu_out_inst_ids[1]),
    .fu_out_valid(fu_out_inst_valid[1]),
    .mem_ren(mem_ren),
    .mem_raddr(mem_raddr),
    .mem_rvalid(mem_rvalid),
    .mem_rdata(mem_rdata),
    .mem_wen(mem_wen),
    .mem_waddr(mem_waddr),
    .mem_wdata(mem_wdata)
);

// Arith FU/Q
arith_fuq_wrap #(
    .INST_ID_BITS(INST_ID_BITS),
    .PRN_BITS(PRN_BITS),
    .MAX_OPERANDS(MAX_OPERANDS),
    .FU_COUNT(FU_COUNT),
    .FU_INDEX(2)
) arith_fuq (
    .clk(clk),
    .rst(rst),
    .inst_valid(inst_valid_inst_demux[2]),
    .queue_ready(queue_ready[2]),
    .inst_id(inst_id_inst_demux[2]),
    .raw_instr(raw_instr_inst_demux[2]),
    .instr_pc(instr_pc_inst_demux[2]),
    .prn_input_valid(prn_input_valid_inst_demux[2]),
    .prn_input_ready(prn_input_ready_inst_demux[2]),
    .prn_input(prn_input_inst_demux[2]),
    .prn_output_valid(prn_output_valid_inst_demux[2]),
    .prn_output(prn_output_inst_demux[2]),
    .set_prn_ready({set_prn_ready[0:1], set_prn_ready[3]}),
    .set_prn({set_prn[0:1], set_prn[3]}),
    .prf_op(prf_op[2]),
    .prf_read_enable(prf_read_enable[2]),
    .prf_read_prn(prf_read_prn[2]),
    .prf_write(prf_write_data[2]),
    .prf_write_enable(prf_write_enable[2]),
    .prf_write_prn(prf_write_prn[2]),
    .fu_out_inst_id(fu_out_inst_ids[2]),
    .fu_out_valid(fu_out_inst_valid[2])
);

// DPI FU/Q
dpi_fuq_wrap #(
    .INST_ID_BITS(INST_ID_BITS),
    .PRN_BITS(PRN_BITS),
    .MAX_OPERANDS(MAX_OPERANDS),
    .FU_COUNT(FU_COUNT),
    .FU_INDEX(3)
) dpi_fuq (
    .clk(clk),
    .rst(rst),
    .inst_valid(inst_valid_inst_demux[3]),
    .queue_ready(queue_ready[3]),
    .inst_id(inst_id_inst_demux[3]),
    .raw_instr(raw_instr_inst_demux[3]),
    .instr_pc(instr_pc_inst_demux[3]),
    .prn_input_valid(prn_input_valid_inst_demux[3]),
    .prn_input_ready(prn_input_ready_inst_demux[3]),
    .prn_input(prn_input_inst_demux[3]),
    .prn_output_valid(prn_output_valid_inst_demux[3]),
    .prn_output(prn_output_inst_demux[3]),
    .set_prn_ready(set_prn_ready[0:2]),
    .set_prn(set_prn[0:2]),
    .prf_op(prf_op[3]),
    .prf_read_enable(prf_read_enable[3]),
    .prf_read_prn(prf_read_prn[3]),
    .prf_write(prf_write_data[3]),
    .prf_write_enable(prf_write_enable[3]),
    .prf_write_prn(prf_write_prn[3]),
    .fu_out_inst_id(fu_out_inst_ids[3]),
    .fu_out_valid(fu_out_inst_valid[3])
);

always_comb
begin
    for (int i = 0; i < FU_COUNT; i++) begin
        for (int j = 0; j < MAX_OPERANDS; j++) begin
            set_prn[i][j] = prf_write_prn[i][j];
            set_prn_ready[i][j] = prf_write_enable[i][j];
            if (prf_write_enable[i][j]) begin
                $display("FU(%D)OP(%D) Readying PRN(%D)", i, j, prf_write_prn[i][j]);
            end
        end

        if (fu_out_inst_valid[i]) begin
            $display("FU(%d) Completed Instruction (ID %d)", i, fu_out_inst_ids[i]);
        end
    end
end

endmodule: inst_router
