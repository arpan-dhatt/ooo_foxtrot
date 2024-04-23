

module fu_dpi (
    fu_if.fu fu
);
    // MOVK
    localparam [31:23] MOVK_3123 = 9'b111100101;
    // MOVZ
  localparam [31:23] MOVZ_3123 = 9'b110100101;
    // ADR
  localparam ADR_31 = 'b0;
  localparam [28:24] ADR_2824 = 5'b10000;
    // ADRP
  localparam ADRP_31 = 'b1;
  localparam [28:24] ADRP_2824 = ADR_2824;


  logic [63:0] a, b, s;
  logic n, z, c, v;
  logic setcond, setrd;
  always_comb begin // TODO for power efficiency, add a check for inst_valid
    a = fu.op[0];
    if(fu.inst[31:22] == ADD_31_22) begin // ADD
      b = {{52{1'b0}}, fu.inst[21:10]}; //imm12 + Xn
      setcond = 1'b0;
      setrd = 1'b1;
    end else if (fu.inst[31:21] == ADDS_31_21 && fu.inst[15:10] == ADDS_15_10) begin // ADDS
      b = fu.op[1]; // Xn + Xm
      setcond = 1'b1;
      setrd = 1'b1;
    end else if (fu.inst[31:22] == SUB_31_22) begin // SUB
      fu.fu_out_data[0] <= fu.op[0] + (~fu.inst[21:10] + 1); // Xn - imm12 = Xn + (~imm12 + 1)
      b = ~{{52{1'b0}}, fu.inst[21:10]} + 1;
      setcond = 1'b0;
      setrd = 1'b1;
    end else if (fu.inst[31:21] == SUBS_31_21 && fu.inst[15:10] == SUBS_15_10) begin // SUBS, CMP
      b = ~fu.op[1] + 1; // Xn - Xm = Xn + (~XM + 1)
      setcond = 1'b1;
      setrd = 1'(fu.inst[4:0] != CMP_04_00);
    end
    {c, s} = a + b;
    n = s[63];
    z = ~(|s);
    v = a[63]^b[63]^s[63]^c;
  end

  always_ff @(posedge fu.clk)
  begin
    if (fu.rst) begin
      fu.fu_out_valid <= 0;
      fu.fu_ready <= 1;
    end else if (fu.inst_valid) begin
      fu.fu_out_data[0] <= s;
      fu.fu_out_data[2] <= {{60{1'b0}}, n, z, c, v};

      fu.fu_out_prn <= fu.out_prn;

      // Output 0 will not be valid on a cmp
      fu.fu_out_data_valid[0] <= setrd;
      fu.fu_out_data_valid[1] <= 1'b0;
      fu.fu_out_data_valid[2] <= setcond;

      fu.fu_out_valid <= fu.inst_valid;
      fu.fu_out_inst_id <= fu.inst_id;
      fu.fu_out_valid <= 1;
    end
  end

endmodule
