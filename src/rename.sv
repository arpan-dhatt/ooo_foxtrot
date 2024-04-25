module rename #(
    parameter ARN_BITS = 6,
    parameter PRN_BITS = 6,
    parameter MAX_OPERANDS = 3
) (
    input logic clk,
    input logic rst,

    input logic input_valid, // inputs to rename are valid
    // arn's from decoder
    input logic [ARN_BITS-1:0] arn_input[MAX_OPERANDS],
    input logic [ARN_BITS-1:0] arn_output[MAX_OPERANDS],

    // PRN's being freed by ROB
    input logic free_valid[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] free_prns[MAX_OPERANDS],

    // PRN inputs
    output logic prn_input_valid[MAX_OPERANDS],
    output logic [PRN_BITS-1:0] prn_input[MAX_OPERANDS],

    // PRN outputs
    output logic prn_output_valid[MAX_OPERANDS],
    output logic [PRN_BITS-1:0] prn_output[MAX_OPERANDS],

    // renamer output is valid (false if not enough PRN's, so stall fe/d)
    output logic mapping_valid,

    // stuff overwritten by instruction for the ROB (will commit them)
    output logic mapping_inputs_valid[MAX_OPERANDS],
    output logic [PRN_BITS-1:0] mapping_inputs_prn[MAX_OPERANDS],
    output logic [ARN_BITS-1:0] mapping_inputs_arn[MAX_OPERANDS]
);

localparam MO_BITS = $clog2(MAX_OPERANDS);

logic get_prns[MAX_OPERANDS];

logic new_prns_valid;

logic [PRN_BITS:0] rem_free_prns;
fifo #(1<<PRN_BITS, PRN_BITS, MAX_OPERANDS) prn_queue (
    .clk(clk),
    .rst(rst),
    .get_en(get_prns),
    .put_en(free_valid),
    .put(free_prns),

    .gotten(prn_output),
    .gotten_valid(new_prns_valid),

    .len(rem_free_prns)
);

typedef struct {
    logic valid;
    logic [PRN_BITS-1:0] prn;
} RemapEntry;

RemapEntry remap_file[1 << ARN_BITS];

logic [MO_BITS-1:0] num_requested_prns;
logic arn_valid[MAX_OPERANDS];
always_comb begin
    // perform the input remapping
    for (int i = 0; i < MAX_OPERANDS; i++) begin
        if (arn_input[i] == ARN_BITS'(62)) begin // invalid
            prn_input_valid[i] = 0;
            prn_input[i] = (1<<PRN_BITS) - 1;
        end else if (arn_input[i] == ARN_BITS'(63)) begin // zero
            prn_input_valid[i] = 0;
            prn_input[i] = 0;
        end else begin // valid ARN (0-32) needs remapping
            prn_input_valid[i] = 1;
            prn_input[i] = remap_file[arn_input[i]].prn;
            if (!remap_file[arn_input[i]].valid) begin
                $display("ERROR: Assigning ARN %0d an empty remap entry!", arn_input[i]);
            end
        end
    end 

    // arn_valid is per-ARN valid for convenience
    for (int i = 0; i < MAX_OPERANDS; i++) begin
        arn_valid[i] = arn_output[i] != ARN_BITS'(62) && arn_output[i] != ARN_BITS'(63);
    end

    // calculate amount of needed PRN's
    num_requested_prns = 0;
    for (int i = 0; i < MAX_OPERANDS; i++) begin
        num_requested_prns = num_requested_prns + arn_valid[i];
    end

    // mappings cannot be valid if we don't have enough PRN's to spare
    if ((PRN_BITS+1)'(num_requested_prns) > rem_free_prns) begin
        mapping_valid = 0;
    end else begin
        mapping_valid = 1;
    end

    // set getter enable for PRN queue
    for (int i = 0; i < MAX_OPERANDS; i++) begin
        get_prns[i] = arn_valid[i] && mapping_valid;
        // also set prn_output_valid since it's the same
        prn_output_valid[i] = get_prns[i];
    end

    // retrieve previous physical register value of remap file to send to ROB
    for (int i = 0; i < MAX_OPERANDS; i++) begin
        mapping_inputs_valid[i] = get_prns[i];
        mapping_inputs_arn[i] = arn_input[i];
        mapping_inputs_prn[i] = remap_file[arn_input[i]].prn;
    end

    // do this since we can
    mapping_valid = new_prns_valid & mapping_valid;
end

always_ff @(posedge clk)
    if (rst) begin
        $display("Resetting Renamer");
        for (int i = 0; i < (1 << ARN_BITS); i++) begin
            remap_file[i].valid <= 0;
        end
    end else if (input_valid && mapping_valid) begin // check state change requested and valid
        // update remap file with newly requested PRN's
        for (int i = 0; i < MAX_OPERANDS; i++) begin
            if (arn_valid[i]) begin
                remap_file[arn_input[i]].valid <= 1;
                remap_file[arn_input[i]].prn <= prn_output[i];
            end
        end
    end
begin
    
end

endmodule
