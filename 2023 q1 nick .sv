


module datapath(clk,in,rsel,Rw,w,Rr,loadA,aluop,loadN,N,out); 
  input clk, rsel, w, loadA, loadN; 
  input [1:0] Rw, Rr, aluop; 
  input [15:0] in;  
  output [15:0] out; 
  output reg N;

  reg [15:0] R0, R1, R2, R3;
  reg [15:0] rin;

  reg [15:0] aout;
  reg [15:0] rout;
  reg aN;
  reg [15:0] A;
  assign out = R1;

always_ff @(posedge clk) begin
    if (w) begin
    case(Rw)
    2'b00: R0 <= rin;
    2'b01: R1 <= rin;
    2'b10: R2 <= rin;
    2'b11: R3 <= rin;
    default: R0 <= 16'bxxxx_xxxx_xxxx_xxxx;   // DON'T FORGET DEFAULT
    endcase
    end

end

always_comb begin
    case (rsel)
    1'b0: rin <= in;
    1'b1: rin <= aout;
    default: rin <= 16'bxxxx_xxxx_xxxx_xxxx;
    endcase
end

always_comb begin
    case (Rr)
    2'b00: rout <= R0;
    2'b01: rout <= R1;
    2'b10: rout <= R2;
    2'b11: rout <= R3;
    default: rout <= 16'bxxxx_xxxx_xxxx_xxxx;
endcase
end

always_ff @(posedge clk) begin
    if (loadA) begin
    A <= rout;
    end
    else begin
    end
end

always_comb begin

    case(aluop)

    2'b00: aout <= rout << 1;
    2'b01: aout <= (rout << 1) + 1;
    2'b10: aout <= {A[7:0],rout[7:0]};
    2'b11: aout <= {8'b0,A[15:8]} - rout;
    default: aout = 16'bxxxx_xxxx_xxxx_xxxx;
    endcase
end

always_comb begin
if (aout[15] == 0)begin
    aN <= 1;
end
else begin
    aN <= 0;
end
    
end

always_ff @(posedge clk) begin
    if (loadN) begin
    N <= aN;
    end
    else begin
    end
end

endmodule
