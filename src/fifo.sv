/*
Multi-Input/Output FIFO Queue:

- can get and put MAX_IO elements at a time
- doesn't support directly passing space freed in same
  cycle to the getters (will be cycle delay)

NOTES:
- any values of gotten that weren't enable in get_en
  have undefined values
- getting more values than are in FIFO is undefined
  behavior
- putting more values than are in FIFO is undefined
  behavior
*/

module fifo #(
    parameter MAX_LENGTH = 64,
    parameter IO_WIDTH = 6,
    parameter MAX_IO = 3
) (
    input logic clk,
    input logic rst,
    input [ML_BITS:0] rst_skip, // skip N values in FIFO on reset

    input logic get_en [MAX_IO],                    // value indices to retrieve from FIFO

    input logic put_en [MAX_IO],                 // valid IO inputs to put into FIFO
    input logic [IO_WIDTH-1:0] put [MAX_IO],        // values visible in next cycle

    output logic [IO_WIDTH-1:0] gotten [MAX_IO],    // values from FIFO

    output logic [ML_BITS:0] len                  // current length of FIFO
);
localparam ML_BITS = $clog2(MAX_LENGTH);
localparam MI_BITS = $clog2(MAX_IO);


logic [IO_WIDTH-1:0] fifo_mem [MAX_LENGTH];
logic [ML_BITS-1:0] fifo_head;
logic [ML_BITS-1:0] fifo_tail;
logic fifo_full;

// number of values getting from FIFO 
logic [MI_BITS-1:0] num_get_values;
// number of values being placed into FIFO
logic [MI_BITS-1:0] num_put_values;
// number of values remaining in FIFO
logic [ML_BITS:0] fifo_len;
// FIFO index offset calculation using prefix sum
logic [MI_BITS-1:0] get_offset[MAX_IO];
logic [MI_BITS-1:0] put_offset[MAX_IO];
always_comb
begin
    num_get_values = 0;
    num_put_values = 0;
    fifo_len = 0;
    if (!rst) begin
        for (int i = 0; i < MAX_IO; i++) begin
            num_get_values = num_get_values + get_en[i];
            num_put_values = num_put_values + put_en[i];
        end

        if (fifo_tail == fifo_head) begin
            fifo_len = fifo_full ? MAX_LENGTH : 0;
        end else if (fifo_head < fifo_tail) begin
            fifo_len = fifo_tail - fifo_head;
        end else begin
            fifo_len = MAX_LENGTH - (fifo_head - fifo_tail);
        end
    end

    for (int i = 0; i < MAX_IO; i++) begin
        get_offset[i] = 0;
        put_offset[i] = 0;
        for (int j = 0; j < i; j++) begin
            get_offset[i] = get_offset[i] + get_en[j];
            put_offset[i] = put_offset[i] + put_en[j];
        end
    end

    for (int i = 0; i < MAX_IO; i++) begin
        gotten[i] = 0;
    end
    // assign output values (for any get_en off value is undefined)
    if (!rst && (ML_BITS+1)'(num_get_values) <= fifo_len) begin
        // move FIFO head downward (will wrap)
        for (int i = 0; i < MAX_IO; i++) begin
            if (get_en[i]) begin
                gotten[i] = fifo_mem[ML_BITS'(fifo_head + (ML_BITS)'(get_offset[i]))];
            end
        end
    end
end


always_ff @(posedge clk)
begin
    if (rst) begin
        // reset fifo values
        $display("Resetting FIFO (skipping %d values)", rst_skip);
        for (logic [ML_BITS:0] i = 0; i < MAX_LENGTH; i++) begin
            fifo_mem[IO_WIDTH'(i)] <= IO_WIDTH'(i);
        end
        fifo_head <= (ML_BITS)'(rst_skip);
        fifo_tail <= 0;
        len <= MAX_LENGTH;
        fifo_full <= 1;
    end else begin
        // $display("num_get_values: %0d, num_put_values: %0d, fifo_len: %0d", num_get_values, num_put_values, fifo_len);
        // $display("Getting [%0d, %0d, %0d] {%0d, %0d, %0d} %0d values, new fifo_head: %0d", 
        // 6'(get_offset[0]) + fifo_head, 6'(get_offset[1]) + fifo_head, 6'(get_offset[2]) + fifo_head, 
        // gotten[0], gotten[1], gotten[2],
        // num_get_values, fifo_head + ML_BITS'(num_get_values));
        // $display("Putting [%0d, %0d, %0d] %0d values, new fifo_tail: %0d", 
        // 6'(put_offset[0]) + fifo_tail, 6'(put_offset[1]) + fifo_tail, 6'(put_offset[2]) + fifo_tail, 
        // num_put_values, fifo_tail + ML_BITS'(num_put_values));

        if ((ML_BITS+1)'(num_get_values) <= fifo_len) begin
            // move FIFO head downward (will wrap)
            fifo_head <= fifo_head + ML_BITS'(num_get_values);
        end else begin
            $display("Cannot get values, fifo_len: %0d, num_get_values: %0d", fifo_len, num_get_values);
        end

        if ((ML_BITS+1)'(num_put_values) + fifo_len <= MAX_LENGTH) begin
            // put values into FIFO
            for (int i = 0; i < MAX_IO; i++) begin
                if (put_en[i]) begin
                    fifo_mem[ML_BITS'(put_offset[i])] <= put[i];
                end
            end

            // move FIFO tail downward (will wrap)
            fifo_tail <= fifo_tail + ML_BITS'(num_put_values);
            // if (num_put_values > 0) begin
                // $display("Putting %0d values, new fifo_tail: %0d", num_put_values, fifo_tail + ML_BITS'(num_put_values));
            // end
        end

        len <= fifo_len + ML_BITS'(num_put_values) - ML_BITS'(num_get_values);
        fifo_full <= fifo_len + ML_BITS'(num_put_values) - ML_BITS'(num_get_values) == MAX_LENGTH;
        // $display("New FIFO length: %0d\n", fifo_len + ML_BITS'(num_put_values) - ML_BITS'(num_get_values));
    end
end
endmodule
