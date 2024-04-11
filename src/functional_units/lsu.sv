module lsu(fu_if iface,
    output logic mem_ren,           // Memory read enable signal
    output logic [63:0] mem_raddr,  // Memory read address
    input logic mem_rvalid,         // Indicates when memory read data is valid
    input logic [63:0] mem_rdata,   // Memory read data
    output logic mem_wen,           // Memory write enable signal
    output logic [63:0] mem_waddr,  // Memory write address
    output logic [63:0] mem_wdata
);
    always @ (posedge iface.clk) begin
        if (iface.inst_valid) begin
            if (iface.inst[31:21] === 11'b11111000010) begin // ldur
                mem_raddr <= op[0] + iface.inst[20:12];
                while(!mem_rvalid);
                iface.out[0].data <= mem_rdata;
                iface.out[0].valid <= 1;
            end else if (iface.inst[31:21] === 11'b11111000000) begin // stur
                mem_waddr <= op[0] + iface.inst[20:12];
                mem_wdata <= op[1];
            end else if (iface.inst[31:22] === 10'b1010100011) begin // ldp
                mem_raddr <= op[0] + iface.inst[21:15];
                while(!mem_rvalid);
                iface.out[0].data <= mem_rdata;
                iface.out[0].valid <= 1;
                mem_raddr <= op[0] + iface.inst[21:15] + 1;
                while(!mem_rvalid);
                iface.out[1].data <= mem_rdata;
                iface.out[1].valid <= 1
            end else if (iface.inst[31:22] === 10'b1010100010) begin // stp
                mem_waddr <= op[0] + iface.inst[21:15];
                mem_wdata <= op[1];
                mem_waddr <= op[0] + iface.inst[21:15] + 1;
                mem_wdata <= op[2];
            end
        end
    end
endmodule