module fed_stage #(
    parameter MAX_OPERANDS=3,
    parameter ARN_BITS=6,
    parameter FU_COUNT=4
) (
    input logic clk,
    input logic rst,

    output logic mem_ren,           // Memory read enable signal
    output logic [63:0] mem_raddr,  // Memory read address
    input logic mem_rvalid,         // Indicates when memory read data is valid
    input logic [63:0] mem_rdata,   // Memory read data

    input logic set_pc_valid,
    input logic [63:0] set_pc,

    output logic output_valid,
    output logic [31:0] raw_instr,
    output logic [63:0] instr_pc,
    output logic [FUC_BITS-1:0] fu_choice,
    output logic [ARN_BITS-1:0] arn_inputs[MAX_OPERANDS],
    output logic [ARN_BITS-1:0] arn_outputs[MAX_OPERANDS]
);

localparam FUC_BITS = $clog2(FU_COUNT);

logic [63:0] pc;

// instruction read buffer
logic irb_valid;
logic [63:0] irb; 

// intermediate stuff for decoder
logic [31:0] iraw_instr;
logic [FUC_BITS-1:0] ifu_choice;
logic [ARN_BITS-1:0] iarn_inputs[MAX_OPERANDS];
logic [ARN_BITS-1:0] iarn_outputs[MAX_OPERANDS];
inst_decoder #(MAX_OPERANDS) decoder (
    .instr_valid(irb_valid),
    .raw_instr(iraw_instr),
    .fu_choice(ifu_choice),
    .arn_inputs(iarn_inputs),
    .arn_outputs(iarn_outputs)
);

always_comb
begin
    // get current instruction from IRB
    iraw_instr = 0;
    if (irb_valid) begin
        // opposite of current pc since reads are 1 cycle behind
        iraw_instr = (pc & 'b111) == 0 ? irb[31:0] : irb[63:32];
    end
end

always_ff @(posedge clk)
begin
    output_valid <= 0;
    if (rst) begin
        $display("Resetting FED Stage");
        irb_valid <= 0;
        pc <= 8;
    end else if (set_pc_valid) begin
        // move the program counter and flush buffers
        irb_valid <= 0;
        pc <= set_pc;
    end else begin
        if (!irb_valid || (pc & 'b111) == 0) begin
            // read if irb empty or pc is aligned (every other cycle)
            mem_ren <= 1;
            mem_raddr <= pc & ~64'b111; // aligned read
        end

        if (mem_rvalid) begin
            irb_valid <= 1;
            irb <= mem_rdata;
        end

        if (irb_valid) begin
            // irb_valid means we for sure have an instruction ready
            output_valid <= 1;
            raw_instr <= iraw_instr;
            instr_pc <= pc - 8; // i thought it would be -4 but -8 seems to be it?
            fu_choice <= ifu_choice;
            arn_inputs <= iarn_inputs;
            arn_outputs <= iarn_outputs;
        end

        // advance pc
        pc <= pc + 4;
    end
end

endmodule
