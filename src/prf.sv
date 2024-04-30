// physical register file

module prf #(
    parameter OP_R_PORTS=4,
    parameter OP_W_PORTS=4,
    parameter S_R_PORTS=0,
    parameter S_W_PORTS=0,
    parameter PRN_BITS = 6,
    parameter MAX_OPERANDS = 3
) (
    input logic clk,
    input logic rst,

    // Ports for read/write MAX_OPERANDS prf's at a time 
    input logic op_ren[OP_R_PORTS][MAX_OPERANDS],
    input logic [PRN_BITS-1:0] op_rprn[OP_R_PORTS][MAX_OPERANDS],
    output logic [63:0] op_rdata[OP_R_PORTS][MAX_OPERANDS],

    input logic op_wen[OP_W_PORTS][MAX_OPERANDS],
    input logic [PRN_BITS-1:0] op_wprn[OP_W_PORTS][MAX_OPERANDS],
    input logic [63:0] op_wdata[OP_W_PORTS][MAX_OPERANDS]

    // ports for read/write one register at a time
    // input logic single_ren[S_R_PORTS],
    // input logic [PRN_BITS-1:0] single_rprn[S_R_PORTS],
    // output logic [63:0] single_rdata[S_R_PORTS],

    // input logic single_wen[S_W_PORTS],
    // input logic [PRN_BITS-1:0] single_wprn[S_W_PORTS],
    // input logic [63:0] single_wdata[S_W_PORTS]
);

logic [63:0] registers[1<<PRN_BITS];

// handle reads
always_comb begin
    // op
    for (int i = 0; i < OP_R_PORTS; i++) begin
        for (int j = 0; j < MAX_OPERANDS; j++) begin
            if (op_ren[i][j]) begin
                op_rdata[i][j] = registers[op_rprn[i][j]];
            end else begin
                op_rdata[i][j] = 0;
            end
        end
    end

    // single
    // for (int i = 0; i < S_R_PORTS; i++) begin
    //     if (single_ren[i]) begin
    //         single_rdata[i] = registers[single_rprn[i]];
    //     end else begin
    //         single_rdata[i] = 0;
    //     end
    // end
end

// handle writes
always_ff @(posedge clk)
begin
    if (rst) begin
        // just zero everything ig
        for (int i = 0; i < 1<<PRN_BITS; i++) begin
            registers[i] <= 0;
        end
    end else begin
        for (int i = 0; i < OP_R_PORTS; i++) begin
            for (int j = 0; j < MAX_OPERANDS; j++) begin
                if (op_wen[i][j]) begin
                    registers[op_wprn[i][j]] <= op_wdata[i][j];
                end
            end
        end
        // single
        // for (int i = 0; i < S_R_PORTS; i++) begin
        //     if (single_wen[i]) begin
        //         registers[single_wprn[i]] <= single_wdata[i];
        //     end
        // end
    end
end

endmodule
