

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
  logic hw, imm;
  always_comb begin // TODO for power efficiency, add a check for inst_valid
    a = fu.op[0];
    if(fu.inst[31:23] == MOVK_3123) begin // MOVK
      s = a; // save old value of register
      hw = fu.inst[22:21];
      imm = fu.inst[20:5];
      case(hw)
        2'b00: s[15:0] = imm;
        2'b01: s[31:16] = imm;
        2'b10: s[47:32] = imm;
        2'b11: s[63:48] = imm;
      endcase
      setcond = 1'b0;
      setrd = 1'b1;
    end else if (fu.inst[31:23] == MOVZ_3123) begin // MOVZ
      hw = fu.inst[22:21];
      imm = fu.inst[20:5];
      s = 64'b0; // zero out the other bits
      case(hw)
        2'b00: s[15:0] = imm;
        2'b01: s[31:16] = imm;
        2'b10: s[47:32] = imm;
        2'b11: s[63:48] = imm;
      endcase
      setcond = 1'b0;
      setrd = 1'b1;
    end else if (fu.inst[31] == ADR_31 && fu.inst[28:24] == ADR_2824) begin // ADR
      s = fu.pc + {45'b0, inst[23:5]}; // add pc + imm
      setcond = 1'b0;
      setrd = 1'b1;
    end else if (fu.inst[31] == ADRP_31 && fu.inst[28:24] == ADRP_2824) begin // ADRP
      b = {fu.pc + inst[23:5], 12'b0}; // add pc + imm, shift left by 12
      setcond = 1'b0;
      setrd = 1'b1;
    end
    s = a + b;
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
