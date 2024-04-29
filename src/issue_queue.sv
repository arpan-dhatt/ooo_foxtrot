module issue_queue #(parameter INST_ID_BITS = 6,
                     parameter PRN_BITS = 6,
                     parameter MAX_OPERANDS = 3, 
                     parameter QUEUE_SIZE = 4, // power of 2
                     parameter FU_COUNT = 4) 
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
    input logic set_prn_ready[FU_COUNT][MAX_OPERANDS],
    input logic [PRN_BITS-1:0] set_prn[FU_COUNT][MAX_OPERANDS],

    // FU control interface
    fu_if.ctrl ctrl,

    // Phy register file interface
    // outputs: enable, prn, inputs: prf_op,
    input logic [63:0] prf_op[MAX_OPERANDS],
    output logic prf_read_enable[MAX_OPERANDS],
    output logic [PRN_BITS - 1:0] prf_read_prn[MAX_OPERANDS]
    );


    typedef struct {
        logic [INST_ID_BITS-1:0] inst_id;
        logic [31:0] inst;

        // Operand metadata and values
        logic                   op_valid[MAX_OPERANDS]; // Which operands are actually utilized
        logic                   op_ready[MAX_OPERANDS]; // Which operands are satisfied
        logic [PRN_BITS-1:0]    op_prn[MAX_OPERANDS]; // Which prn is it waiting on 

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

    IQentry chosen_instruction;
    logic [$clog2(QUEUE_SIZE) - 1: 0] index;
    always_comb begin
        for(int i = 0; i < QUEUE_SIZE - 1; i++) begin
            if(queue_state[i] != EMPTY_STATE) begin
                queue_state[i] = (queue[i].op_ready == queue[i].op_valid) ? READY_STATE : queue_state[i];
            end
        end

        for(int i = 0; i < QUEUE_SIZE; i++) begin
            if(queue_state[(index + i) % QUEUE_SIZE] == READY_STATE) begin
                // inst_id, inst, op, out_prn, pc, inst_valid,
                // chosen_instruction.inst_id = queue[(index + i) % QUEUE_SIZE].inst_id;
                // chosen_instruction.inst = queue[(index + i) % QUEUE_SIZE].inst;
                // chosen_instruction.out_prn = queue[(index + i) % QUEUE_SIZE].out_prn;
                // chosen_instruction.op_valid = queue[(index + i) % QUEUE_SIZE].op_valid;
                // chosen_instruction.op_prn = queue[(index + i) % QUEUE_SIZE].op_prn;
                // chosen_instruction.pc = queue[(index + i) % QUEUE_SIZE].pc;
                chosen_instruction = queue_state[(index + i) % QUEUE_SIZE];

                index = (index + i) % QUEUE_SIZE; // Round robin
                break;
            end
        end

        // Ensures that operands in prf are ready when we hit insertion
        prf_read_enable = chosen_instruction.op_ready; 
        prf_read_prn = chosen_instruction.op_prn;

        queue_ready = queue_state.and == EMPTY_STATE; // TODO make sure this reduction is valid in verilator, see IEEE 1800-2017 7.12.3
        
    end

    always_ff @(posedge ctrl.clk) begin
        if(ctrl.rst) begin
            for(int i = 0; i < QUEUE_SIZE; i++) begin
                queue_state[i] <= EMPTY_STATE;
                queue[i] <= '0;
                index <= '0;
                chosen_instruction <= '0;
            end
        end else begin
        
            // Handle instruction insert
            if(queue_inst_valid && queue_ready) begin
                for(int i = 0; i < QUEUE_SIZE; i++) begin
                    if(queue_state[i] == EMPTY_STATE) begin
                        queue_state[i] <= WAITING_STATE;
                        queue[i].inst_id <= inst_id;
                        queue[i].inst <= raw_instr;

                        queue[i].op_valid <= prn_input_valid;
                        queue[i].op_ready <= prn_input_ready;
                        queue[i].op_prn <= prn_input;

                        queue[i].out_prn <= prn_output;
                        queue[i].pc <= instr_pc;
                        break;
                    end
                end
            end

            // Handle prn status update
            for(int i = 0; i < QUEUE_SIZE; i++) begin
                for(int k = 0; k < FU_COUNT; k++) begin
                    for(int j = 0; j < MAX_OPERANDS; j++) begin
                        if((queue_state[i] != EMPTY_STATE) && queue[i].op_valid[j] && queue[i].op_prn[j] == set_prn[k][j] && set_prn_ready[k][j]) begin
                            queue[i].op_ready[j] <= 1'b1;
                        end
                    end
                end
            end

            // Issue instruction to attached fu if one is Ready (zeroing out old entry)
                // Loop through entries checking for Ready state
            if(ctrl.fu_ready && queue_state[index] == READY_STATE) begin
                //  inst_id, inst, op, out_prn, pc, inst_valid,
                ctrl.inst_id <= chosen_instruction.inst_id;
                ctrl.inst <= chosen_instruction.inst;
                ctrl.op <= prf_op; // TODO Might need to handle 0 register
                ctrl.out_prn <= chosen_instruction.out_prn;
                ctrl.pc <= chosen_instruction.pc;

                ctrl.inst_valid <= 1'b1;

                chosen_instruction <= '0;
                queue[index] <= '0; // Empty the entry
            end else begin
                ctrl.inst_valid <= '0;
            end

            index <= index;
        end
    end

endmodule: issue_queue