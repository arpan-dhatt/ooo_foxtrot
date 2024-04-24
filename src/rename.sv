module rename #(
    parameter PRN_BITS = 6,
    parameter MAX_OPERANDS = 3
) (
    input logic clk,
    input logic rst,

    input logic lrns_valid,
    input logic [5:0] lrn_input[MAX_OPERANDS],
    input logic [5:0] lrn_output[MAX_OPERANDS],

    input logic free_valid[MAX_OPERANDS * 2],
    input logic [PRN_BITS-1:0] free_prns[MAX_OPERANDS * 2],

    output logic [PRN_BITS-1:0] prn_input[MAX_OPERANDS],
    output logic [PRN_BITS-1:0] prn_output[MAX_OPERANDS],
    output logic prns_valid
);

localparam OP_BITS = $clog2(MAX_OPERANDS);
localparam [5:0] INVALID_LRN = 62;
localparam [5:0] ZERO_LRN = 63;

// maximum of PRN_BITS**2 PRN's can be available at a time 
logic [PRN_BITS-1:0] free_prn_fifo[1 << PRN_BITS];
logic [PRN_BITS-1:0] fifo_head;
logic [PRN_BITS-1:0] fifo_tail;

// current logical to physical register mapping
typedef struct packed {
    logic [PRN_BITS-1:0] prn;
    logic valid;
} Entry;
Entry lrn_to_prn[1 << 5:0];

// the number of new registers needed to satisfy lrn_output
logic [PRN_BITS:0] num_requested_regs;
// the number of registers being reclaimed
logic [PRN_BITS:0] num_freed_regs;
// the number of physical registers remaining IN FIFO
logic [PRN_BITS:0] phys_remaining;
// total number of physical registers remaining including reclaimed this cycle
logic [PRN_BITS:0] phys_available;
always_comb
begin

    prn_input = lrn_output;
    num_requested_regs = (
        (lrn_output[0] != INVALID_LRN && lrn_output[0] != ZERO_LRN ? 1 : 0)
        + (lrn_output[1] != INVALID_LRN && lrn_output[1] != ZERO_LRN ? 1 : 0)
        + (lrn_output[2] != INVALID_LRN && lrn_output[2] != ZERO_LRN ? 1 : 0)
    );

    num_freed_regs = 0;
    for (int i = 0; i < MAX_OPERANDS*2; i++) begin
        num_freed_regs = free_valid[i] ? num_freed_regs + 1 : num_freed_regs;
    end

    if (fifo_tail == fifo_head) begin
        phys_remaining = 1 << PRN_BITS;
    end else if (fifo_head < fifo_tail) begin
        phys_remaining = fifo_tail - fifo_head;
    end else begin
        phys_remaining = (1 << PRN_BITS) - (fifo_head - fifo_tail);
    end

    phys_available = {phys_remaining + num_freed_regs}[PRN_BITS:0];
end

always_ff @(posedge clk)
begin

    if (rst) begin
        // reset free PRN fifo
        $display("Resetting PRN FIFO");
        for (int i = 0; i < (1 << PRN_BITS); i++) begin
            free_prn_fifo[i] <= 6'(i);
        end
        fifo_head <= 0;
        fifo_tail <= 0;

        // reset lrn to prn mappings
        $display("Resetting LRN to PRN mapping");
        for (int i = 0; i < (1 << 6); i++) begin
            lrn_to_prn[i].valid <= 0;
        end
    end else if (lrns_valid) begin
        $display("---------------------------------");
        $display("Number of requested registers: %0d", num_requested_regs);
        $display("Number of freed registers:     %0d", num_freed_regs);
        $display("Physical registers in FIFO:    %0d", phys_remaining);
        $display("Total available registers:     %0d", phys_available);
        $display("---------------------------------");

        // map lrns to prns for the inputs (simple)
        for (int i = 0; i < MAX_OPERANDS; i++) begin
            prn_input[i] <= lrn_input[i] != INVALID_LRN && lrn_input[i] != ZERO_LRN ? 
                            lrn_to_prn[lrn_input[i]].prn : 0;
            if (lrn_input[i] != INVALID_LRN && lrn_input[i] != ZERO_LRN) begin
                $display("  Logical[%d] mapped to Physical[%d]", lrn_input[i], lrn_to_prn[lrn_input[i]].prn);
            end
        end

        // handle allocation
        if (num_requested_regs > phys_available) begin
            // not enough physical registers remaining to give away
            prns_valid <= 0;
        end else begin
            // allocate the physical registers
            if (num_requested_regs == num_freed_regs) begin
                // pass register ownership directly without touching FIFO
            end else if (num_requested_regs < num_freed_regs) begin
                // pass needed registers and store rest in FIFO
            end else if (num_requested_regs > num_freed_regs) begin
                // take all freed registers and also take from FIFO
            end
            prns_valid <= 1;
        end
    end
end

endmodule
