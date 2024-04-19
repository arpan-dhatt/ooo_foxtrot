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
    localparam [9:0] LDP = 10'b1010100011;
    localparam [9:0] STP = 10'b1010100010;

    always_ff @ (posedge iface.clk) begin
        if (iface.rst) begin
            is_p <= 0;
            iface.fu_out_valid <= 0;
            iface.fu_ready <= 1;
        end else if (iface.inst_valid) begin
            if (iface.inst[31:21] === LDUR) begin // ldur
                mem_ren <= 1;
                mem_raddr <= op[0] + iface.inst[20:12];
                iface.fu_out_data[0] <= mem_rdata;
                iface.fu_out_data_valid[0] <= mem_rvalid;
            end else if (iface.inst[31:21] === STUR) begin // stur
                mem_wen <= 1;
                mem_waddr <= op[0] + iface.inst[20:12];
                mem_wdata <= op[1];
            end else if (iface.inst[31:22] === LDP) begin // ldp
                if (!iface.fu_ready) begin
                    iface.fu_ready <= 1;
                    mem_ren <= 1;
                    mem_raddr <= op[0] + iface.inst[21:15] + 1;
                    iface.fu_out_data[1] <= mem_rdata;
                    iface.fu_out_data_valid[1] <= mem_rvalid;
                end else begin
                    iface.fu_ready <= 0;
                    mem_ren <= 1;
                    mem_raddr <= op[0] + iface.inst[21:15];
                    iface.fu_out_data[0] <= mem_rdata;
                    iface.fu_out_data_valid[0] <= mem_rvalid;
                end
            end else if (iface.inst[31:22] === STP) begin // stp
                if (!iface.fu_ready) begin
                    iface.fu_ready <= 1;
                    mem_wen <= 1;
                    mem_waddr <= op[0] + iface.inst[21:15] + 1;
                    mem_wdata <= op[1];
                end else begin
                    iface.fu_ready <= 0;
                    mem_wen <= 1;
                    mem_waddr <= op[0] + iface.inst[21:15];
                    mem_wdata <= op[1];
                end                
            end
        end
    end
endmodule