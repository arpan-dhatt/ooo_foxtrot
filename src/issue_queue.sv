module issue_queue #(parameter INST_ID_BITS = 6,
                     parameter PRN_BITS = 6,
                     parameter MAX_OPERANDS = 3, 
                     parameter QUEUE_SIZE = 4) // power of 2
    (
    // Issue queue control
    input logic inst_valid,
    output logic queue_ready,

    // Single instruction receive (From renamer)
    input logic [INST_ID_BITS-1:0] inst_id,
    input logic [31:0] raw_instr,
    input logic [63:0] instr_pc,
    input logic prn_input_valid[MAX_OPERANDS],
    input logic prn_input_ready[MAX_OPERANDS], // Ready to read from PRF
    input logic [PRN_BITS-1:0] prn_input[MAX_OPERANDS],
    input logic prn_output_valid[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] prn_output[MAX_OPERANDS],

    // Active prn status update (From all FUs)
    input logic peek_valid,
    input logic [PRN_BITS-1:0] peek_prn,
    input logic [63:0] peek_value,

    // FU control interface
    fu_if.ctrl ctrl,

    // Phy register file interface
    // outputs: enable, prn, inputs: prf_op,
    input logic prf_op[MAX_OPERANDS],
    output logic prf_read_enable[MAX_OPERANDS],
    output logic prf_read_prn[MAX_OPERANDS]
    );


    typedef struct  {
        logic [INST_ID_BITS-1:0] inst_id;
        logic [31:0] inst;

        // Operand metadata and values
        logic                   op_valid[MAX_OPERANDS]; // Which operands are actually utilized
        logic                   op_ready[MAX_OPERANDS]; // Which operands are satisfied
        logic [PRN_BITS-1:0]    op_prn[MAX_OPERANDS]; // Which prn is it waiting on 
        logic [63:0]            op[MAX_OPERANDS]; // Value of a satisfied operand 

        // Additional pass-through data
        logic [PRN_BITS-1:0] out_prn[MAX_OPERANDS];  // Output physical register numbers
        logic [63:0] pc;  // Program counter
    } IQentry;

    localparam EMPTY_STATE = 2'b00; // Empty entry
   // localparam WAITING_PRF_READ_STATE = 2'b01; // Waiting for initial PRF read
    localparam WAITING_STATE = 2'b10; // Waiting for dynamic prn snoops
    localparam READY_STATE = 2'b11; // Read for dispatch

    logic [1:0] queue_state[0: QUEUE_SIZE - 1];
    IQentry queue[0: QUEUE_SIZE - 1];

    always_comb begin
        for(int i = 0; i < QUEUE_SIZE - 1; i++) begin
            if(queue_state[i] != EMPTY_STATE) begin
                queue_state[i] = (queue[i].op_ready == queue[i].op_valid) ? READY_STATE : queue_state[i];
            end
        end

        // Ensures that operands in prf are ready when we hit insertion
        if(inst_valid) begin
            prf_read_enable = prn_input_ready; 
            prf_read_prn = prn_input;
        end

        queue_ready = queue_state.and == EMPTY_STATE; // TODO make sure this reduction is valid in verilator, see IEEE 1800-2017 7.12.3
        
    end

    logic [$clog2(QUEUE_SIZE): 0] entry_count;
    logic [$clog2(QUEUE_SIZE) - 1: 0] index;

    always_ff @(posedge ctrl.clk) begin
        if(ctrl.rst) begin
            for(int i = 0; i < QUEUE_SIZE; i++) begin
                queue_state[i] <= EMPTY_STATE;
                queue[i] <= '0;
            end
        end else begin
        
            // Handle instruction insert
            if(queue_inst_valid && (queue_state.and == EMPTY_STATE)) begin
                for(int i = 0; i < QUEUE_SIZE; i++) begin
                    if(queue_state[i].state == EMPTY_STATE) begin
                        queue_state[i].state <= WAITING_STATE;
                        queue[i].inst_id <= inst_id;
                        queue[i].inst <= raw_instr;

                        queue[i].op_valid <= prn_input_valid;
                        queue[i].op_ready <= prn_input_ready;
                        queue[i].op_prn <= prn_input;
                        queue[i].op <= prf_op;

                        queue[i].out_prn <= prn_output;
                        queue[i].pc <= instr_pc;
                        break;
                    end
                end
            end

            // Handle prn status update
            if(peek_valid) begin
                for(int i = 0; i < QUEUE_SIZE; i++) begin
                    for(int j = 0; j < MAX_OPERANDS; j++) begin
                        if((queue_state[i] != EMPTY_STATE) && queue[i].op_valid[j] && queue[i].op_prn[j] == peek_prn) begin
                            queue[i].op_ready[j] <= 1'b1;
                            queue[i].op[j] <= peek_value;
                            break;
                        end
                    end
                end
            end

            // Issue instruction to attached fu if one is Ready (zeroing out old entry)
                // Loop through entries checking for Ready state
            if(ctrl.fu_ready) begin
                for(int i = 0; i < QUEUE_SIZE; i++) begin
                    if(queue_state[(index + i) % QUEUE_SIZE].state == READY_STATE) begin
                        // inst_id, inst, op, out_prn, pc, inst_valid,

                        ctrl.inst_id <= queue[(index + i) % QUEUE_SIZE].inst_id;
                        ctrl.inst <= queue[(index + i) % QUEUE_SIZE].inst;
                        ctrl.op <= queue[(index + i) % QUEUE_SIZE].op; // TODO Might need to handle 0 register
                        ctrl.out_prn <= queue[(index + i) % QUEUE_SIZE].out_prn;
                        ctrl.pc <= queue[(index + i) % QUEUE_SIZE].pc;

                        ctrl.inst_valid <= 1'b1;

                        index <= (index + i) % QUEUE_SIZE; // Round robin
                        queue[(index + i) % QUEUE_SIZE] <= '0; // Empty the entry
                        break;
                    end
                end
            end
        end
    end

endmodule: issue_queue