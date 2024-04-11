// Prints out the alphabet, then sets done

module cpu(
    input logic clk,                // Clock signal
    input logic rst,                // Reset signal
    output logic done,              // Indicates when the CPU has finished execution
    output logic mem_ren,           // Memory read enable signal
    output logic [63:0] mem_raddr,  // Memory read address
    input logic mem_rready,         // Indicates when memory read data is ready
    input logic [63:0] mem_rdata,   // Memory read data
    output logic mem_wen,           // Memory write enable signal
    output logic [63:0] mem_waddr,  // Memory write address
    output logic [63:0] mem_wdata   // Memory write data
);
    logic [63:0] char_to_write;
    assign mem_wdata = char_to_write;
    assign mem_waddr = 64'hffffffffffffffff;
    always @(posedge clk) begin
        if (rst) begin
            char_to_write <= 64'h40;
            mem_wen <= 0;
        end else begin
            char_to_write <= char_to_write + 1;
            mem_wen <= 1;
        end
        if (char_to_write > 64'h58) begin
            done <= 1;
        end
    end
endmodule