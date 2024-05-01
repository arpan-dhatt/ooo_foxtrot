module fu_lsu(fu_if.fu iface,
    output logic mem_ren,           // Memory read enable signal
    output logic [63:0] mem_raddr,  // Memory read address
    input logic mem_rvalid,         // Indicates when memory read data is valid
    input logic [63:0] mem_rdata,   // Memory read data
    output logic mem_wen,           // Memory write enable signal
    output logic [63:0] mem_waddr,  // Memory write address
    output logic [63:0] mem_wdata
);
    localparam [10:0] LDUR = 11'b11111000010;
    localparam [10:0] STUR = 11'b11111000000;
    localparam [9:0] LDP = 10'b1010100101;
    localparam [9:0] STP = 10'b1010100100;
                               

    logic pending_read;
    logic pending_write;
    logic pending_ldp;
    logic second_ldp;
    logic pending_ldp_read;
    logic pending_stp;
    logic second_stp;
    logic pending_stp_write;

    always_ff @ (posedge iface.clk) begin
        if (iface.rst) begin
            iface.fu_out_valid <= 0;
            pending_read <= 0;
            iface.fu_out_data_valid[0] <= 0;
            iface.fu_out_data_valid[1] <= 0;
            iface.fu_out_data_valid[2] <= 0;
            iface.fu_ready <= 1;
        end else if (iface.inst_valid) begin
            iface.fu_ready <= 0;
            iface.fu_out_prn <= iface.out_prn;
            iface.fu_out_prn_valid <= iface.out_prn_valid;
            iface.fu_out_data_valid <= iface.out_prn_valid;
            iface.fu_out_inst_id <= iface.inst_id;
            //$display("%b", iface.inst);
            if (iface.inst[31:21] === LDUR) begin // ldur
                iface.fu_out_valid <= 0;
                //$display("%s", "LDUR");
                pending_read <= 1;
                mem_ren <= 1;
                mem_raddr <= iface.op[0] + {{55{iface.inst[20]}}, iface.inst[20:12]};
            end else if (iface.inst[31:21] === STUR) begin // stur
                //$display("%s", "STUR");
                iface.fu_out_valid <= 0;
                mem_wen <= 1;
                pending_write <= 1;
                mem_waddr <= iface.op[0] + {{55{iface.inst[20]}}, iface.inst[20:12]};
                mem_wdata <= iface.op[1];
            end else if (iface.inst[31:22] === LDP) begin // ldp
                //$display("%s", "LDP");
                iface.fu_out_valid <= 0;
                pending_ldp <= 1;
                mem_ren <= 1;
                mem_raddr <= iface.op[0] + {{57{iface.inst[21]}}, iface.inst[21:15]};
            end else if (iface.inst[31:22] === STP) begin // stp
                //$display("%s", "STP");
                iface.fu_out_valid <= 0;
                pending_stp <= 1;
                mem_wen <= 1;
                mem_waddr <= iface.op[0] + {{57{iface.inst[21]}}, iface.inst[21:15]};
                mem_wdata <= iface.op[1];             
            end
        end else if (pending_read) begin
            //$display("%s", "LDUR2");
            iface.fu_out_data[0] <= mem_rdata;
            iface.fu_out_data_valid[0] <= mem_rvalid;
            iface.fu_out_valid <= mem_rvalid;
            mem_ren <= 0;
            pending_read <= 0;
            iface.fu_ready <= 1;
        end else if (pending_stp) begin
            if (pending_stp_write) begin
                iface.fu_ready <= 1;
                iface.fu_out_valid <= 1;
                pending_stp <= 0;
                pending_stp_write <= 0;
                mem_wen <= 0;
                iface.fu_out_data_valid[0] <= 0;
                iface.fu_out_data_valid[1] <= 0;
                iface.fu_out_data_valid[2] <= 0;
            end else if (second_stp) begin
                second_stp <= 0;
                pending_stp_write <= 1;
                mem_wen <= 1;
                mem_waddr <= iface.op[0] + {{57{iface.inst[21]}}, iface.inst[21:15]} + 64'b1000;
                mem_wdata <= iface.op[2];
            end else begin
                mem_wen <= 0;
                second_stp <= 1;
            end
        end else if (pending_ldp) begin
            if (pending_ldp_read) begin
                iface.fu_ready <= 1;
                iface.fu_out_data[1] <= mem_rdata;
                iface.fu_out_data_valid[1] <= mem_rvalid;
                iface.fu_out_valid <= 1;
                mem_wen <= 0;
                pending_ldp_read <= 0;
                pending_ldp <= 0;
            end else if (second_ldp) begin
                pending_ldp_read <= 1;
                second_ldp <= 0;
                iface.fu_ready <= 1;
                mem_ren <= 1;
                mem_raddr <= iface.op[0] + {{57{iface.inst[21]}}, iface.inst[21:15]} + 64'b1000;
            end else begin
                second_ldp <= 1;
                iface.fu_out_data[0] <= mem_rdata;
                iface.fu_out_data_valid[0] <= mem_rvalid;
                mem_ren <= 0;
            end
        end else if (pending_write) begin
            //$display("%s", "LDUR2");
            mem_wen <= 0;
            iface.fu_out_data_valid[0] <= 0;
            iface.fu_out_data_valid[1] <= 0;
            iface.fu_out_data_valid[2] <= 0;
            iface.fu_out_valid <= 1;
            iface.fu_ready <= 1;
            pending_write <= 0;
        end else begin
            mem_wen <= 0;
            mem_ren <= 0;
            iface.fu_out_valid <= 0;
        end
    end
endmodule